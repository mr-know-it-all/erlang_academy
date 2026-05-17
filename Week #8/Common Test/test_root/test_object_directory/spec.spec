{alias, state, "./demo/"}.
{alias, meeting, "./meeting/"}.
{logdir, "./logs/"}.
 
{suites, meeting, all}.
{suites, state, all}.
{skip_cases, demo, basic_SUITE, test2, "This test fails on purpose"}.