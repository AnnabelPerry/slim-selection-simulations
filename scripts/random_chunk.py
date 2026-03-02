import numpy as np
import pandas as pd
import argparse
from io import StringIO
import os
import sys
import time

def get_random_CHROM(input_directory):
    dx = pd.read_csv(f"{input_directory}/non_overlapping_full_span_partition.tsv", sep='\t')
    chrom_size = dx.groupby('chrom').apply(lambda x: x['end'].max()-x['start'].min(), include_groups=False)
    p_chr = chrom_size/chrom_size.sum()
    CHROM = int(np.random.choice(p_chr.index.tolist(), p=p_chr.tolist()))
    return CHROM
    
def random_chunk(CHROM, window,input_directory):
    dx = pd.read_csv(f"{input_directory}/non_overlapping_full_span_partition.tsv", sep='\t')
    dr0 = pd.read_csv(f"{input_directory}/genetic_map_hg19_withX.txt.gz", sep=' ')
    
    l = []
    for i, x in dx.groupby('chrom'):
        r = x.groupby('type')['size'].sum()/x['size'].sum()
        r['chrom'] = int(i)
        l+=[r]
    r = pd.concat(l, axis=1).T.set_index('chrom')['coding']
    mean_chr_ratio  = r.loc[CHROM]
    print('chrom:', CHROM, '\ncoding ratio (+-50%):', mean_chr_ratio, '\nwindow size (+-10%):', window, '\nno_recombination_maxGAP <', '20Kbp')
    while True:
        I = (dx['chrom']==CHROM)&(dx['type']=='coding')
        pos = dx.loc[I].sample(1).iloc[0]['start']
        # pos = 22220482
        I = ((dx['start']-pos).abs()<(window/2))&(dx['chrom']==CHROM)
        x = dx.loc[I]
        size = x['size'].sum()
        ratio = x.groupby('type')['size'].sum()/size
        re = ratio.loc['coding']
    
        I = (dr0['chr']==CHROM)
        dr = dr0.loc[I].copy()
        dr['end'] = dr['position'].shift(-1)
        I = (dr['end']>=x['start'].min())&(dr['position']<=x['end'].max())
        dr = dr.loc[I]
        dr['size'] = dr['end']-dr['position']
        I = (dr['COMBINED_rate(cM/Mb)']==0)&(dr['size']>0)
        if sum(I)>0:
            no_recombination_maxGAP = dr.loc[I, 'size'].max()
        else:
            no_recombination_maxGAP = 0
        
        flag = (abs(re-mean_chr_ratio)<0.5*mean_chr_ratio)&(abs(size-window)<(0.1*window))&(no_recombination_maxGAP<20e3)
        if flag:
            break
        else:
            print('Try again!', 'coding ratio:', re, 'size:', size, 'no_recombination_maxGAP:', no_recombination_maxGAP)
    print('Final!', 'coding ratio:', re, 'size:', size, 'no_recombination_maxGAP:', no_recombination_maxGAP)
    return x

if __name__ == '__main__':
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter)

    parser.add_argument('-chrom', type=int, required=False)
    parser.add_argument('-windowsize', type=float, required=True)
    parser.add_argument('-out', type=str, required=True)
    parser.add_argument('-input_directory', type=str, required=True)

    args = parser.parse_args()
    print(args)
    
    chrom = args.chrom
    windowsize = args.windowsize
    out = args.out
    if chrom is None:
        chrom = get_random_CHROM(input_directory)
        print('random chrom', chrom)
    df = random_chunk(chrom, windowsize,input_directory)
    df.to_csv(f'{out}', sep='\t', index=None)
