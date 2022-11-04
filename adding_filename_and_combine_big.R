###########################################################
## R script for making huge data from list of text files ##
###########################################################

library(dplyr)

setwd('~/Desktop/straglr_scoring_tool_for_long_read/TERT_repeat_region_projects/HPRC_pac_straglr_TERT_3_4_repeat_output/')

ref = read.delim('../../toolinpus_and_HPRC_bams/clp_target_hg38_TERT_R3_R4.bed',header = F)
ref$repname = gsub("_[A-Z]+$","",ref$V4)
ref = ref[,c(1:3,5)]
colnames(ref) = c('chrom','start','end','repeatname')

filenames <- list.files(pattern = "*.tsv")
data2=lapply(filenames, read.delim2, header=T, skip=1)
for (i in 1:length(data2)){
  ff=gsub('set3_',"",filenames[i])
  ff = gsub('.tsv',"",ff)
 # print(ff)
  data2[[i]]<-cbind(data2[[i]],ff)}

# combined all the files into one dataset
# do.call() == constructs and executes a function call from a name or a function
# and a list of arguments to be passed to it.
data_rbind <- do.call("rbind", data2)
colnames(data_rbind) = c("chrom", "start" , "end", "repeat_unit", "genotype" ,   "read"    ,    "copy_number", "size"  ,"read_start",  "allele"      ,"sample_name")


####
# combined ref to the dataset
####

finall = dplyr::left_join(data_rbind,ref,by = c("chrom",'start','end'))

pp = finall[,c(11,1:4,5,6,12,10)]

# subset the data

pp_R3 = subset(pp,pp$repeatname =='TERT_R3')
pp_R4 = subset(pp, pp$repeatname =='TERT_R4')

# make unique, using dplyr is good stuff

unique(pp_R4 %>% select(-7)) 


write.table(pp_R4,'~/Desktop/HPRC_pacbio_TERT_R4_all_copy_read.txt',quote = F,col.names = T,row.names = F ,sep = '\t')

# for loop to get the id of each sample
tar = unique(f1$sample_name)
nb = unique()

for (i in tar){
  seqid = subset(pp_R4,pp_R4$sample_name == i ) 
  seqid = seqid[,c(7)]
  write.table(seqid,file = paste0('~/Desktop/straglr_scoring_tool_for_long_read/toolinpus_and_HPRC_bams/MaternalPaternal_and_TERT_SNPs/TERT_R3_R4_to_copy/HPRC_all_pac_seq_read_id/',i,'.txt'),quote = F,col.names = F,row.names = F,sep = '\t')
}

################################
################################
########################################
setwd('~/Desktop/straglr_scoring_tool_for_long_read/MaternalPaternal_and_TERT_SNPs/TERT_R3_R4_to_copy/pac_seq_read_id/')

f1 = read.delim2('~/Desktop/straglr_scoring_tool_for_long_read/MaternalPaternal_and_TERT_SNPs/TERT_R3_R4_to_copy/HPRC_pacbio_TERT_R4_all_copy_read.txt')
f1 = f1[,c(1,9,7,8)]

tar = unique(f1$sample_name)
nb = unique(f1$allele)

for (i in tar){
  seqid = subset(f1,f1$sample_name == i ) 
  nb = unique(seqid$allele)
  if(length(nb) == 1){
    print('only one copy')
    seqid = seqid[,c(1,2,3)]
    write.table(seqid,file = paste0(i,'.txt'),quote = F,col.names = T,row.names = F,sep = '\t')
    }
  else{
    print('have 2 copy read!')
    nwid = subset(f1,sample_name == i & allele == nb[1])
    nwid = nwid[,c(1,2,3)]
    write.table(nwid,file = paste0(i,'_1','.txt'),quote = F,col.names = T,row.names = F,sep = '\t')
    nwid2 = subset(f1,sample_name == i & allele == nb[2])
    nwid2 = nwid2[,c(1,2,3)]
    write.table(nwid2,file = paste0(i,'_2','.txt'),quote = F,col.names = T,row.names = F,sep = '\t')
    }
  }




f1 = read.delim2('~/Desktop/straglr_scoring_tool_for_long_read/MaternalPaternal_and_TERT_SNPs/TERT_R3_R4_to_copy/HPRC_pacbio_TERT_R4_all_copy_read.txt')
f1 = f1[,c(1,9,7,8)]
f2 = subset(f1,allele == 95.8 & sample_name == 'HG00438')
seqq = f2$read

write.table(seqq, '~/Desktop/straglr_scoring_tool_for_long_read/MaternalPaternal_and_TERT_SNPs/TERT_R3_R4_to_copy/pac_seq_read_id/438_2.txt',quote = F,col.names = F,row.names = F,sep = '\t')
