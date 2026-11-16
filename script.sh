
#!/bin/bash

# Go through each Testcase directory
for num in 1 2 3 4
do
    # Remove the old output directory
    rm -rf "Testcase${num}Diff"

    # Check every .1.txt file
    for file1 in Testcase${num}/*.1.txt
    do
        # Get the matching .2.txt file
        file2="${file1%.1.txt}.2.txt"

        # Get the output filename
        output="${file1##*/}"
        output="${output%.1.txt}Diff.txt"

        # Compare the two files
        if ! cmp -s "$file1" "$file2"
        then
            # Create the output directory if needed
            mkdir -p "Testcase${num}Diff"

            # Save the differences
            diff -u "$file1" "$file2" > "Testcase${num}Diff/$output"
        fi
    done
done
