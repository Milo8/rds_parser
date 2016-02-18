function ptyn = locate_ptyn(PTYN, chars, ab_flag, ptyn_seg, c)
    first = vbin2dec(ptyn_seg);
    if c == 0
        PTYN(first:first+3) = chars;
    else
        PTYN(firts:first+3) = chars;
end