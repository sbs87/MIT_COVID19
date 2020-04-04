# MIT_COVID19
MIT Covid-19 Hackathon

Prompt: 
Who to test and when?
How do we appropriately and more efficiently identify patients and health care workers that should be tested for COVID-19? With limited testing available and results taking longer to result, how can we speed up the process and better triage the testing and the test reporting? How can we identify and monitor patients and health care workers who may be at higher-risk exposure or have pre-existing conditions that might be more adversely affected? How do we predict who will worsen rapidly and need higher level care more urgently?

Idea:
Problem: Not enough available tests. Are the right people getting tested? Are certain communities at higher risk? People generally want to get a sense of their risk given their location.  <br>
SS addition: There is currently not an efficient method to prioritize tests for optimized COVID-19 surveying. <br>
Solution: Quantify risk for more efficient/optimial COVID-19 testing prioritization. If we can group communities based on relative risk, then we can create a mapping of this level of risk to each community. Use historical covid-19 infection rates, hospital resources, transportation/commuter stats, community demographics. 

Ideally, in a snapshot of time, we can predict the additional relative growth in that population (ie. additional 2% of that population will get infected). And the output, to make more interpretable, will be "Risk" defined as a normalized 0-1 version of this predicted value. Our cost function will be evaluable since we are measuring the relative growth, which we can infer from the data. And the relative risk will be evaluated on a per-day basis.
