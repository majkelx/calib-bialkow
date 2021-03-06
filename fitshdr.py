#! /usr/bin/env python
"""Module contains some operations on FITS headers  (MK)

    - processing:
        process_header(in_hdr, rules, ...) -> out_hdr
      sample rules ar defined in 'sample_log_rules'

    - logs creation
        stream_log_for_files(filename_iterable, ostream, rules...)
        stream_log_for_catalog(catalog_filename, ...)
        stream_log_for_path (fits_path_name, ...)

    - header updates
        update_hdr_for_files(filename_iterable, rules)

    The main data structure for these routines is pyfits.Header.
    For rules parameter, use list of rules: tuples:
        (string_key, rule_function)
    where
        string_key -  key on which result has to be stored in resulting FITS header
            when writing logs, name isn't imported, may be copied as a name of a column.
        rule_function - has to follow specification:
                foo(string_key, header, **args) -> value
                foo(string_key, header, **args) -> (value, comment)
            where
                string_key - as above, key where result is to be stored
                header - input pyfits.Header object to take data from,
                **args - additional arguments passed to rules.
            Rule_function can return single value which will be stored in an output
            header or a tuple with this value and FITS card comment.
            There are predefined rules:
                'rcopy' - copy key form input to output without modification
                'rfile' - used to pass FITS filename to output
            Examples rule function, note that header object can be treated as dict:
                lambda k, h, **args: '{:06.2f}'.format(h['exptime'])
                lambda k, h, **args: '{EXPTIME:+06.2f}'.format(**h)
            See also great guide for formatting output: https://pyformat.info
"""

import pyfits
import sys
import os

# Predefined rules (key, pyfits.Header, **opt) -> value

# rule for copying card without modification
def rcopy(k, h, **args): return h.get(k)

# rule to add an filename provided in **args
def rfile(k, h, filename, **args): return filename

# write your own rules, e.g:
# r = lambda k, h, **args: '{:06.2f}'.format(h['exptime'])
#

sample_log_rules = [
    ('FILE', rfile),
    ('HH', lambda k, h, **args: h['ut'][0:2]),
    ('MM', lambda k, h, **args: h['ut'][3:5]),
    ('SS', lambda k, h, **args: h['ut'][6:8]),
    ('OBJECT', rcopy),
    ('FILTER', rcopy),
    ('DATA-TYP', rcopy),
    ('FILTER', rcopy),
]


def process_header(hdr, rules, clear=True, **rules_args):
    """ Generate new Header according to rules

    hdr - input pyfits.Header object
    rules - list of tuples ('KEY', rule function)
        each function should follow spec:
            foo(key, header, **args) -> value
        rule gets new key and original Header object and should return
        value for key in output header or None to change nothing.
    clear - if true output contain only cards produced by rules, otherwise
        rules output is applied to original header
    returns resulting pyfits.Header object
    """
    ret = pyfits.Header() if clear else hdr
    for key, rule in rules:
        val = rule(key, hdr, **rules_args)
        if val is not None:
            ret[key] = val
    return ret


def stream_header_values(hdr, stream, delimiter=' '):
    """stream line of header values

    Usefull for writing logs form FITS
    hdr - pyfits.Header object
    stream - output stream
    delimiter - values delimiter
    """
    for v in hdr.values():
        stream.write(v)
        stream.write(delimiter)


def lineof_header_values(hdr, delimiter=' '):
    """return line of header values

    Usefull for writing logs form FITS
    hdr - pyfits.Header object
    delimiter - values delimiter
    returns string with values
    """
    import StringIO
    o = StringIO.StringIO()
    stream_header_values(hdr, o, delimiter)
    ret = o.getvalue()
    o.close()
    return ret


def update_hdr(hdr, rules, **rule_params):
    """updates FITS header according to rules

    hdr     - pyfits.Header
    rules   - list of tuples ('KEY', rule function) see: 'process_header'
    """
    process_header(hdr, rules, clear=False, **rule_params)


def update_hdr_for_files(filename_iterable, rules, autofix=True, **rule_params):
    """updates FITS headers according to rules

    filename_iterable - iterator for FITS filenames
    rules - list of tuples ('KEY', rule function) see: 'process_header'
    autofix - whether do pyfits.verify('silentfix') or not
                True  - can change some wrong cards silently,
                False - can cause errors on access to wrong card
    """
    for f in filename_iterable:
        f = f.strip()
        huds = pyfits.open(f, mode='update')
        if autofix:
            huds[0].verify('silentfix')
            huds.flush(output_verify='silentfix')
        srchdr = huds[0].header
        update_hdr(srchdr, rules, filename=os.path.basename(f), **rule_params)
        huds.flush(output_verify='ignore')
        huds.close()


def stream_log_for_files(
        filename_iterable,
        stream,
        rules=sample_log_rules,
        delimiter=' ',
        comment_char='#',
        top_comment=None,
        include_column_names_comment=False,
        sort_key=None,
        sort_rev=False,
        **rule_params):
    """stream log of processed FITS headers

    filename_iterable - iterator for FITS filenames
    stream - output stream
    rules - list of tuples ('KEY', rule function) see: 'process_header'
    delimiter - columns delimiter
    top_comment - to be put as comment on first line of file
    include_column_names_comment - generate header comment with column names
    """
    if top_comment is not None:
        stream.write(comment_char + top_comment + '\n')
    if include_column_names_comment:
        stream.write(comment_char + delimiter.join([column for column, __ in rules]) + '\n')
    lines = []  # used when sort
    for f in filename_iterable:
        f = f.strip()
        huds = pyfits.open(f)
        huds[0].verify('silentfix')
        srchdr = huds[0].header
        loghdr = process_header(srchdr, rules, clear=True, filename=os.path.basename(f), **rule_params)
        if sort_key is None:
            stream_header_values(loghdr, stream, delimiter)
            stream.write('\n')
        else:
            lines.append({'sortkey': loghdr[sort_key], 'line': lineof_header_values(loghdr, delimiter)})
        huds.close()
    if sort_key is not None:
        lines.sort(reverse=sort_rev, key=lambda el: el['sortkey'])
        for line in lines:
            stream.write(line['line']+'\n')


def stream_log_for_path(
        fits_path_name='*.fits',
        stream=sys.stdout,
        rules=sample_log_rules,
        delimiter=' ',
        comment_char='#',
        top_comment=None,
        include_column_names_comment=False,
        **rule_params):
    """write log of processed FITS headers

    fits_path_name - UNIX path and pattern for files to include in log
    stream - file to write
    rules - list of tuples ('KEY', rule function) see: 'process_header'
    delimiter - columns delimiter
    top_comment - to be put as comment on first line of file
    include_column_names_comment - generate header comment with column names
    """
    import glob
    stream_log_for_files(
        glob.iglob(fits_path_name),
        stream,
        rules,
        delimiter,
        comment_char,
        top_comment,
        include_column_names_comment,
        **rule_params)


def stream_log_for_catalog(
        catalog_filename,
        stream=sys.stdout,
        rules=sample_log_rules,
        delimiter=' ',
        comment_char='#',
        top_comment=None,
        include_column_names_comment=False,
        **rule_params):
    """write log of processed FITS headers

    catalog_filename - filename of catalog file with list of FITS filenames
    stream - file to write
    rules - list of tuples ('KEY', rule function) see: 'process_header'
    delimiter - columns delimiter
    top_comment - to be put as comment on first line of file
    include_column_names_comment - generate header comment with column names
    append - if file 'log_filename' exists, append instead of overwrite
    """
    with open(catalog_filename) as f:
        stream_log_for_files(
            f,
            stream,
            rules,
            delimiter,
            comment_char,
            top_comment,
            include_column_names_comment,
            **rule_params)

if __name__ == "__main__":
    stream_log_for_path(include_column_names_comment=True)
