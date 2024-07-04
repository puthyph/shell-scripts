#!/bin/bash

csv_file=$1

if [ $# -ne 1 ]; then
    echo "Usage: $0 <csv_file>"
    exit 1
fi

if [ ! -f "$csv_file" ]; then
    echo "Incorrect CSV file: $csv_file"
    exit 1
fi

curl_builder() {
    curl_command_verbose="curl -s '$protocol://$fqdn/$context_path/$api_path'"
    curl_command="$curl_command_verbose -o /dev/null -w %{http_code}"

    for header in "${headers_array[@]}"; do
      curl command+=" -H '$header'"
    done
}

curl_executor() {
    CURL_HTTP_CODE=$(eval $CURL_COMMAND)
    CURL_ERROR_VERBOSE=$(eval $CURL_COMMAND_VERBOSE)
}

curl_validator() {
    if [[ $CURL_HTTP_CODE == $status_code ]]; then
        echo "Return code of $context_path/$api_path call is compliant (HTTP STATUS $STATUS_CODE)"
    else
        echo "Return code of $context_path/$api_path call is not right, HTTP STATUS $CURL_HTTP_CODE instead of $STATUS_CODE"
        echo "Error log:"
        echo "$CURL_ERROR_VERBOSE"
    fi
}

csv_reader() {
    while IFS=';' read -r protocol fqdn context_path api_path status_code headers
    do
        export STATUS_code=$status_code
        IFS='|' read -r -a headers_array <<< "$headers"

        curl_builder
        curl_executor
        curl_validator

    done < "$csv_file"
}

csv_reader
