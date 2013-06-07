<cfscript>
testSuite = createObject("component","mxunit.framework.TestSuite").TestSuite();
testSuite.addAll("TestBase32");
testSuite.addAll("TestKey");
results = testSuite.run();
writeOutput(results.getResultsOutput('html'));
</cfscript>