import cftime
import re
import os
import argparse
from glob import glob

parser = argparse.ArgumentParser()
parser.add_argument('sd', type=float, help="START_TIME")
parser.add_argument('ed', type=float, help="STOP_TIME")
parser.add_argument('pin', type=str, help="path to source")
parser.add_argument('pout', type=str, nargs='?', help="output path",
                    default=os.path.join(os.getcwd(), "river"))
parser.add_argument('-u', '--unit', type=str,
                    default="days since 1979-01-01 00:00:00")
args = parser.parse_args()

if not os.path.isdir(args.pout):
    os.mkdir(args.pout)

convert = lambda d, u1, u2: cftime.date2num(cftime.num2date(d, u1), u2)

header = {'flow': ("## COLUMNS 2\n##\n## COLUMN1.name time\n"
"## COLUMN1.long_name Time\n## COLUMN1.units {}\n##\n## COLUMN2.name flow\n"
"## COLUMN2.long_name River flow\n## COLUMN2.units m3s-1\n".format(args.unit)),
'temp': ("## COLUMNS 2\n##\n## COLUMN1.name time\n## COLUMN1.long_name Time\n"
"## COLUMN1.units {}\n##\n## COLUMN2.name temp\n"
"## COLUMN2.long_name Temperature\n## COLUMN2.units degC\n".format(args.unit))}

for vname in ['temp', 'flow']:
    for path in glob(os.path.join(args.pin, "*{}.ts".format(vname))):
        with open(os.path.join(args.pout, os.path.basename(path)), 'w') as fo:
            with open(path, 'r') as fi:
                fo.write(header[vname])
                it = -2
                prev = 0, "0"
                for line in fi:
                    if line.startswith('#'):
                        matcht = re.search("N(\d+).name time", line)
                        if matcht:
                            it = int(matcht.group(1))
                        matchu = re.search("N{}.units (.*)$".format(it), line)
                        if matchu:
                            in_units = matchu.group(1)
                            start_date = convert(args.sd, args.unit, in_units)
                            end_date = convert(args.ed, args.unit, in_units)
                            ref = cftime.date2num(cftime.datetime(2016, 1, 1),
                                                  in_units)  # fixme
                            shift = ((start_date - ref) // 365.25) * 365.25
                            new_start = start_date - shift
                            new_end = end_date - shift
                        matchv = re.search("N(\d+).name {}".format(vname), line)
                        if matchv:
                            iv = int(matchv.group(1)) - 1
                    else:
                        date, val = float(line.split()[it-1]), line.split()[iv]
                        if date >= new_start:
                            fo.write(str(convert(prev[0] + shift, in_units, args.unit)) + " " + prev[1] + "\n")
                            if date > new_end:
                                fo.write(str(convert(date + shift, in_units, args.unit)) + " " + val + "\n")
                                break
                        prev = date, val
