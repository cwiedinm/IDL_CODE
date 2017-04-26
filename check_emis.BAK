pro check_emis

close, /all

infile = 'D:\Data2\wildfire\EPA_EI\MODEL\OUTPUT\OUTPUT_FEB23_2009\FIREEMIS_2008_02232009.txt'

inload3=ascii_template(infile)
emis=read_ascii(infile, template=inload3)

numfires = n_elements(emis.field01)

end