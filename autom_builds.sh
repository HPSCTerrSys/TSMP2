#!/usr/bin/env bash
#
# Ana González-Nicolás
# a.gonzalez-nicolas@fz-juelich.de

# USER INFO
input_file="config_autom_builds.in"

# ----------------------------------------------------
# Summary log filename
SUMMARY_LOG="autom_builds_summary_$(date +%Y%m%d_%H%M%S).log"

log_summary() {
    echo "[$(date '+%F %T')] $*" | tee -a "$SUMMARY_LOG"
}


if [[ -z "$input_file" ]]; then
  echo "Usage: $0 <input-file>"
  exit 1
fi

combs=()
envs=()
options=""

section=""

# Robust parser (handles whitespace, casing, CRLF)
#
# The condition `[[ -n "$rawline" ]]` ensures the last line of
# `input_file` is read even without a trailing newline
while IFS= read -r rawline || [[ -n "$rawline" ]]; do
    line="$(echo "$rawline" | xargs)"      # trim whitespace
    [[ -z "$line" ]] && continue           # skip blank lines

    ULINE=$(echo "$line" | tr '[:lower:]' '[:upper:]')

    if [[ "$ULINE" == "COMBINATIONS:" ]]; then
        section="combinations"
        continue
    fi

    if [[ "$ULINE" == "ENVIRONMENTS:" ]]; then
        section="environments"
        continue
    fi

    if [[ "$ULINE" == "OPTIONS:" ]]; then
        section="options"
        continue
    fi

    case "$section" in
        "combinations") combs+=("$line") ;;
        "environments") envs+=("$line") ;;
        "options") options+=" $line" ;;
    esac

done < "$input_file"

echo "Starting sequential builds..."
log_summary "BEGIN RUN: ${SYSTEMNAME^^}"
log_summary " "

SYSTEMNAME_UPPER=${SYSTEMNAME^^}

for combo in "${combs[@]}"; do
    # Build model_id: comp1 comp2 → comp1-comp2
    model_id=$(echo "$combo" | tr ' ' '-')

    # Convert combo → flags: comp1 comp2 → --comp1 --comp2
    combo_flags=""
    for comp in $combo; do
        combo_flags+=" --$comp"
    done

    for env in "${envs[@]}"; do

        log_summary "START: combination=\"$combo\" environment=\"$env\""

        cmd="./build_tsmp2.sh $combo_flags --env env/$env --force_update $options"
		log_summary "$cmd"

		if eval "$cmd"; then
		
            # Success
            bld_src="bld/${SYSTEMNAME_UPPER}_${model_id}"
            bin_src="bin/${SYSTEMNAME_UPPER}_${model_id}"

            bld_dest="bld/${SYSTEMNAME_UPPER}_${model_id}_${env}"
            bin_dest="bin/${SYSTEMNAME_UPPER}_${model_id}_${env}"

            # Rename directories
            if [[ -d "$bld_src" ]]; then mv "$bld_src" "$bld_dest"; fi
            if [[ -d "$bin_src" ]]; then mv "$bin_src" "$bin_dest"; fi

            log_summary "SUCCESS: combo=\"$combo\", env=\"$env\" → $bld_dest, $bin_dest"
            log_summary " "

        else
            # Failure
            bld_src="bld/${SYSTEMNAME_UPPER}_${model_id}"
            bin_src="bin/${SYSTEMNAME_UPPER}_${model_id}"

            bld_failed="bld/${SYSTEMNAME_UPPER}_${model_id}_${env}_FAILED"
            bin_failed="bin/${SYSTEMNAME_UPPER}_${model_id}_${env}_FAILED"

            [[ -d "$bld_src" ]] && mv "$bld_src" "$bld_failed"
            [[ -d "$bin_src" ]] && mv "$bin_src" "$bin_failed"

            log_summary "FAILED: combo=\"$combo\", env=\"$env\" → $bld_failed, $bin_failed"
            log_summary ""
            exit 1

        fi

    done
done

log_summary "RUN COMPLETED."
echo "All builds completed successfully."
