#!/bin/bash

set_auth() {
  local s3cnf="$HOME/.s3cfg"

  if [ -e "$s3cnf" ]; then
    warn '.s3cfg file already exists in home directory and will be overwritten'
  fi

  echo '[default]' > "$s3cnf"
  echo "access_key=$WERCKER_S3GET_KEY_ID" >> "$s3cnf"
  echo "secret_key=$WERCKER_S3GET_KEY_SECRET" >> "$s3cnf"

  debug "generated .s3cfg for key $WERCKER_S3GET_KEY_ID"
}

main() {
  set_auth

  info 'starting s3 synchronisation'

  if [ ! -n "$WERCKER_S3GET_KEY_ID" ]; then
    fail 'missing or empty option key_id, please check wercker.yml'
  fi

  if [ ! -n "$WERCKER_S3GET_KEY_SECRET" ]; then
    fail 'missing or empty option key_secret, please check wercker.yml'
  fi

  if [ ! -n "$WERCKER_S3GET_BUCKET_URL" ]; then
    fail 'missing or empty option bucket_url, please check wercker.yml'
  fi

  source_files="$WERCKER_ROOT/$WERCKER_S3GET_SOURCE_FILES"
  if cd "$source_dir";
  then
      debug "changed directory $source_dir, content is: $(ls -l)"
  else
      fail "unable to change directory to $source_dir"
  fi

  set +e
  local GET="$WERCKER_STEP_ROOT/s3cmd get --verbose $WERCKER_S3SYNC_BUCKET_URL/$source_files"
  debug "$GET"
  local get_output=$($GET)

  if [[ $? -ne 0 ]];then
      echo "$get_output"
      fail 's3get failed';
  else
      echo "$get_output"
      success 'finished s3 file retrieval';
  fi
  set -e
}

main
