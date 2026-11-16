
#!/bin/bash

# Check all four Testcase directories
overall=0

for num in 1 2 3 4
do
    testcase="Testcase${num}"
    diffdir="Testcase${num}Diff"

    pass=1
    has_diff=0
    expected_count=0

    # Examine every pair
    for file1 in "$testcase"/*.1.txt
    do
        file2="${file1%.1.txt}.2.txt"

        output="${file1##*/}"
        output="${output%.1.txt}Diff.txt"
        outputfile="$diffdir/$output"

        if cmp -s "$file1" "$file2"
        then
            # Identical files must not have an output file
            if [ -e "$outputfile" ]
            then
                pass=0
                echo "Unexpected file: $outputfile" >&2
            fi
        else
            # Different files need an output file
            has_diff=1
            expected_count=$((expected_count + 1))

            if [ ! -f "$outputfile" ]
            then
                pass=0
                echo "Missing file: $outputfile" >&2
            else
                # Ignore the first two lines (timestamps)
                expected=$(diff -u "$file1" "$file2" | tail -n +3)
                actual=$(tail -n +3 "$outputfile")

                if [ "$expected" != "$actual" ]
                then
                    pass=0
                    echo "Incorrect contents: $outputfile" >&2
                fi
            fi
        fi
    done

    # Check whether the output directory should exist
    if [ "$has_diff" -eq 1 ]
    then
        if [ ! -d "$diffdir" ]
        then
            pass=0
            echo "Missing directory: $diffdir" >&2
        else
            actual_count=$(find "$diffdir" -maxdepth 1 -type f | wc -l)

            if [ "$actual_count" -ne "$expected_count" ]
            then
                pass=0
                echo "Incorrect number of output files in $diffdir" >&2
            fi
        fi
    else
        if [ -e "$diffdir" ]
        then
            pass=0
            echo "Unexpected directory: $diffdir" >&2
        fi
    fi

    # Print exactly one result per Testcase
    if [ "$pass" -eq 1 ]
    then
        echo "Testcase${num}: PASS"
    else
        echo "Testcase${num}: FAIL"
        overall=1
    fi
done

exit "$overall"
