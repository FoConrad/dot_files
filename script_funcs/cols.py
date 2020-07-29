#!/usr/bin/env python

import re
import sys
import argparse

def get_starts(line, delim):
    return [0] + map(lambda i: i.start(), re.finditer(delim, line))#[:-1]

def map_col_list(line, col_list, starts):
    cols_strs = []

    for ind, col_start in enumerate(starts):
        if not ((ind+1) in col_list): continue

        if ind == len(starts)-1:
            cols_strs.append(line[col_start: ])
        else:
            cols_strs.append(line[col_start: starts[ind+1]])
    return cols_strs


def main(args):
    check_col = args.col_list
    if args.col_blacklist:
        check_col.black_list = True

    for linum, line in enumerate(map(str.rstrip, sys.stdin)):
        if linum == 0:
            starts = get_starts(line, args.delim)
            if args.no_header: continue

        print ''.join(map_col_list(line, check_col, starts))


class ColList(object):
    @staticmethod
    def to_sets(str_arg):
        end_points = map(int, str_arg.split(':'))
        assert len(end_points) <= 2, 'Only two endpoints in range'
        return set(range(end_points[0], end_points[-1] + 1))

    def __init__(self, col_list):
        self._invert = False
        self._white_list = reduce(set.union, map(
            self.to_sets, col_list.split(',')))

    @property
    def black_list(self):
        return self._invert

    @black_list.setter
    def black_list(self, value):
        self._invert = value

    def __contains__(self, ind):
        present = ind in self._white_list
        return not present if self.black_list else present

    def __repr__(self):
        return '{}{}'.format('not ' if self.black_list else '',
                             self._white_list)

class ColumnsAction(argparse.Action):
    def __init__(self, option_strings, dest, **kwargs):
        super(ColumnsAction, self).__init__(
            option_strings, dest, **kwargs)
    def __call__(self, parser, namespace, values, option_string=None):


        vals = ColList(values)
        setattr(namespace, self.dest, vals)

def get_parser():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('col_list', action=ColumnsAction,
                        metavar='COL-LIST', help='comma seperated list'
                        ' indexes wr index ranges (a:b) to be included '
                        'in output')
    parser.add_argument('--delim', '-d', type=str, metavar='DELIM-RE',
                        default='\s{2,}')
    parser.add_argument('--no-header', '-H', action='store_true',
                        help='remove first line if it is col headers')
    parser.add_argument('--col-blacklist', '-b', action='store_true',
                        help='print all columns EXCXEPT those in '
                        'col-list')
    return parser.parse_args()

if __name__ == '__main__':
    main(get_parser())
