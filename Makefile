# ----------------------------------------------------------- #
# This makefile runs a script (INFOSCRIPT) in rails server    #
# folder on designated SERVER machine. INFOSCRIPT - amongst   #
# other things - copies CRONFILE to its destination.          #
# ----------------------------------------------------------- #
# The problem here is that the demo machine is a virtual      #
# apache server on the same machine as the test machine.      #
# 'demo' and 'test' differs only in actual paths.             #
# Long story short: kludgey solution with lots of duplication:#
# * three cronscripts ('demo', test, 'live')                  #
# * libris_neg_responses.sh and libris_user_requests.sh has   #
#   to be parameterized as per target directory               #
# ----------------------------------------------------------- #
# ----------------------------------------------------------- #
TEST_SERVER=130.241.16.49
TEST_SERVERNAME=fjarrkontrollen-server-test.ub.gu.se
TEST_DEPDIR=/data/rails/illbackend
TEST_INFOSCRIPT=${TEST_DEPDIR}/create-deploy-info.sh
# ----------------------------------------------------------- #
DEMO_SERVER=130.241.16.49
DEMO_SERVERNAME=fjarrkontrollen-server-demo.ub.gu.se
DEMO_DEPDIR=/data/demo/illbackend
DEMO_INFOSCRIPT=${DEMO_DEPDIR}/create-deploy-info.sh
# ----------------------------------------------------------- #
LIVE_SERVER=130.241.35.161
LIVE_SERVERNAME=fjarrkontrollen-server.ub.gu.se
LIVE_DEPDIR=/data/rails/illbackend
LIVE_INFOSCRIPT=${LIVE_DEPDIR}/create-deploy-info.sh
# ----------------------------------------------------------- #
DEPHOST=`hostname`
APPENV=production

all:
	@echo -n "run like this:"
	@echo    "'make test'"
	@echo -n "           or:"
	@echo    "'make demo'"
	@echo -n "           or:"
	@echo    "'make live'"

deploy_test:
	ssh -X rails@${TEST_SERVER} ${TEST_INFOSCRIPT} ${USER}:${DEPHOST} ${TEST_SERVERNAME} test ${TEST_DEPDIR}

demo:
	ssh -X rails@${DEMO_SERVER} ${DEMO_INFOSCRIPT} ${USER}:${DEPHOST} ${DEMO_SERVERNAME} $@ ${DEMO_DEPDIR}

live:
	ssh -X rails@${LIVE_SERVER} ${LIVE_INFOSCRIPT} ${USER}:${DEPHOST} ${LIVE_SERVERNAME} $@ ${LIVE_DEPDIR}
