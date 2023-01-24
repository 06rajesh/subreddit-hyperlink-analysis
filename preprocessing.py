import csv
from datetime import datetime


FLOOR_DATE = datetime(2014, 1, 1)
CEILING_DATE = datetime(2014, 12, 31)


# trim the csv file and store only
# source and target subreddit column
# between floor and celing date range
def load_csv(path: str, outpath: str):
    dataframe = []
    with open(path, newline='') as csvfile:
        lines = csv.reader(csvfile, delimiter='\t')
        counter = 0
        for row in lines:
            if counter == 0:
                counter += 1
                continue
            # elif counter >= 10:
            #     break
            item = []
            source = row[0].lower()
            target = row[1].lower()
            timestamp = datetime.strptime(row[3], '%Y-%m-%d %H:%M:%S')
            if FLOOR_DATE < timestamp < CEILING_DATE:
                item.append(source)
                item.append(target)
                item.append(timestamp.strftime("%Y-%m-%d"))
                dataframe.append(item)
                counter += 1

    outfile = outpath + '.csv'
    columns = ['from', 'to', 'date']
    with open(outfile, 'w') as f:
        wr = csv.writer(f)
        wr.writerow(columns)
        wr.writerows(dataframe)

    print("Output finished")


def load_save_text_propery(path: str, outpath: str):
    dataframe = []
    with open(path, newline='') as csvfile:
        lines = csv.reader(csvfile, delimiter='\t')
        counter = 0
        for row in lines:
            if counter == 0:
                counter += 5
                continue
            # elif counter >= 10:
            #     break
            item = []
            source = row[0].lower()
            post_props = row[5]
            timestamp = datetime.strptime(row[3], '%Y-%m-%d %H:%M:%S')
            if FLOOR_DATE < timestamp < CEILING_DATE:
                item.append(source)
                props_splitted = post_props.split(',')
                item.extend(props_splitted)
                dataframe.append(item)
                counter += 1

    outfile = outpath + '.csv'
    columns = ['subreddit']
    columns.extend([str(i+1) for i in range(86)])
    print(columns)
    with open(outfile, 'w') as f:
        wr = csv.writer(f)
        wr.writerow(columns)
        wr.writerows(dataframe)

    print("Output finished")


if __name__ == '__main__':
    src = "dataset/soc-redditHyperlinks-title.tsv"
    output = "dataset/preprocessed-post-vector"
    load_save_text_propery(src, output)
