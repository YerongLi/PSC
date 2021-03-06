#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function

import argparse
from distutils.version import LooseVersion
import json

from dipy.tracking.streamlinespeed import length
import nibabel as nib
import numpy as np

from scilpy.io.utils import assert_inputs_exist


if LooseVersion(nib.__version__) < LooseVersion('2.1.0'):
    raise ImportError("Unable to import the Nibabel streamline API. "
                      "Nibabel >= v2.1.0 is required")


def _build_arg_parser():
    parser = argparse.ArgumentParser(
        description='Compute streamlines min, mean and max length, as well as '
                    'standard deviation of length in mm',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('input', help='Fiber bundle file')
    parser.add_argument('--indent', type=int, default=2,
                        help='Indent for json pretty print')
    parser.add_argument('--sort_keys', action='store_true',
                        help='Sort keys in output json')

    return parser


def main():
    parser = _build_arg_parser()
    args = parser.parse_args()

    assert_inputs_exist(parser, [args.input])

    tractogram_file = nib.streamlines.load(args.input)
    streamlines = tractogram_file.streamlines

    lengths = list(length(streamlines))

    print(json.dumps({'min_length': float(np.min(lengths)),
                      'mean_length': float(np.mean(lengths)),
                      'max_length': float(np.max(lengths)),
                      'std_length': float(np.std(lengths))},
                     indent=args.indent, sort_keys=args.sort_keys))


if __name__ == '__main__':
    main()
