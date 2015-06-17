#!/usr/bin/env bash

set -x

setup_dynamodb_local() {

    dynamodb_tar_file="dynamodb_local_2015-04-27_1.0.tar.gz"
    dynamodb_dir=$HOME/dynamodb_local

    if ! test -f "$HOME/$dynamodb_tar_file"
    then
      wget --directory-prefix=$HOME -- "http://dynamodb-local.s3-website-us-west-2.amazonaws.com/${dynamodb_tar_file}"
    fi
    mkdir -p "$dynamodb_dir"
    tar -xf $HOME/$dynamodb_tar_file -C ${dynamodb_dir}

}

test "$SNAP_CI" == "true" && setup_dynamodb_local

export AWS_ACCESS_KEY_ID='foo'
export AWS_SECRET_ACCESS_KEY='bar'
export AWS_REGION="us-west-2"

export BUNDLE_PATH="${SNAP_CACHE_DIR}/bundle-cache/tiny_ddb"

export JRUBY_OPTS=" -Xcli.debug=true --debug "

bundle install

bundle exec rspec spec/dynamodb_unavailable/ ; unavail_exit_status=$?

test "$unavail_exit_status" -eq 0 || exit $unavail_exit_status

pushd $dynamodb_dir
    java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb -inMemory & dynamodb_pid=$!
popd

sleep 10
curl -s http://127.0.0.1:8000 ; dynamodb_local=$?

if test "$dynamodb_local" -eq 0
then
    echo "DynamoDB_Local is up, all tests should pass"
else
    echo "DynamoDB_Local setup failed, persistence tests will fail" 1>&2
fi

bundle exec rspec spec/dynamodb_available/ ; avail_exit_status=$?

test "$SNAP_CI" == "true" && test -n "$dynamodb_pid" && kill -15 $dynamodb_pid

exit $avail_exit_status
