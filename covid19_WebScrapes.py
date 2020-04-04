#!/usr/bin/env python

from urllib.request import urlopen
import requests
from bs4 import BeautifulSoup
import numpy as np
import pandas as pd
import algosdk
import math
import time


class TestingData_Scraper() :

    def __init__(self) :

        self.url = "https://covidtracking.com/data"
        html = urlopen(self.url)
        self.soup = BeautifulSoup(html, 'html.parser')

        self.state_urls = self.Scrape_StateURL()

    def Scrape_StateURL(self) :

        all_states = self.soup.findAll(class_='data-state css-wlrcyf')
        all_states_list = [all_states[i].findAll('h3')[0].getText() for i in range(len(all_states))]
        state_urls = np.zeros((len(all_states),2),dtype='O')
        for i,state in enumerate(all_states) :
            state_urls[i][0] = state.findAll('h3')[0].getText()
            for a in state.findAll(class_="list-unstyled")[0].findAll('a') :
                if 'historical' in a['href'] :
                    state_urls[i][1] = self.url + a['href'][5:]
                continue
        return state_urls     

    def Scrape_Stats(self) :

        count = 0
        to_create = pd.DataFrame()
        for state,url in self.state_urls :
            html_state = urlopen(url)
            soup_state = BeautifulSoup(html_state, 'html.parser')
            historical_table = soup_state.findAll(class_='state-historical')[0]
            if count == 0 : #pull column header if first occurrence
                column_headers = [head.getText() for head in historical_table.findAll('thead')[0].findAll('th')]
                ind_drop = column_headers.index('Screenshot') 
                column_headers.pop(ind_drop)
                self.column_headers = column_headers
                count = 1
            rows = list(historical_table.findAll('tbody')[0])
            to_append = []
            for row in rows :
                to_append.append([item.getText() for item in row.findAll('td')])
            to_append = np.delete(np.array(to_append),ind_drop,axis=1)
            to_append = pd.DataFrame(to_append,columns=column_headers)
            to_append['State'] = state
            to_create = to_create.append(to_append)

        return to_create



class Algorand_Scrape():
    
    def __init__(self, api_key):
        self.purestake_api_key = api_key
        self.connectMainnet()
        self.client_check()
        
        # For retrieving the real covid data from mainnet
        self.address = "COVIDR5MYE757XMDCFOCS5BXFF4SKD5RTOF4RTA67F47YTJSBR5U7TKBNU"
        self.fromRound = 5646000
        self.maxTxnPerCall = 500 # max transactions in a batch
        batchSize = 512 #Read the transactions from the blockchain in 512-block installations
        self.params = self.algod_client.suggested_params()
        self.lastRound = self.params['lastRound']
        #self.lastRound = self.fromRound + 20*self.batchSize # for testing
        
        print("\n total rounds:",self.lastRound - self.fromRound)
        
        self.txns = []
        
        rnd = self.fromRound
        while rnd < self.lastRound:
            toRnd = rnd + batchSize
            if toRnd > self.lastRound:
                toRnd = self.lastRound
            to_add = self.getTransactionBatch(rnd,toRnd) # Fetch transactions for these rounds
            self.txns.extend(to_add)  
            rnd += batchSize
            time.sleep(.1) #added because was overloading 
        print("found {} transactions".format(len(self.txns)))
                             
    def connectMainnet(self):
        algod_address_mainnet = "https://mainnet-algorand.api.purestake.io/ps1"
        port = ""
        token = {
            'X-API-key' : self.purestake_api_key,
        }
        # Initialize the algod client
        self.algod_client = algosdk.algod.AlgodClient(port, algod_address_mainnet, token) 
    
    def client_check(self):
        try:
            status = self.algod_client.status()
        except Exception as e:
            print("Failed to get algod status: {}".format(e))

        if status:
            print("algod last round: {}".format(status.get("lastRound")))
            print("algod time since last round: {}".format(status.get("timeSinceLastRound")))
            print("algod catchup: {}".format(status.get("catchupTime")))
            print("algod latest version: {}".format(status.get("lastConsensusVersion")))

        # Retrieve latest block information                                                                                                                                               
        last_round = self.algod_client.status().get("lastRound")
        print("####################")
        block = self.algod_client.block_info(last_round)
        print(block)
                             
    def getTransactionBatch(self,fromRnd,toRnd):
        if (fromRnd > toRnd):# sanity check
            return []
        txs = self.algod_client.transactions_by_address(self.address,fromRnd,toRnd,self.maxTxnPerCall) 
        # make an API call to get the transactions - 500 at a time

        #  A recursive function for getting a batch of transactions, to overcome
        # the limitation of maxTxnPerCall transaction per call to the API
        if (fromRnd == toRnd) | (len(txs['transactions']) < self.maxTxnPerCall) :
            return txs['transactions']
        else :
            midRnd = math.floor((fromRnd+toRnd) / 2)
            txns1 = getTransactionBatch(fromRnd, midRnd)
            txns2 = getTransactionBatch(midRnd+1, toRnd)
            return txns1.concat(txns2)
                             
    def get_txns(self):
        return self.txns
