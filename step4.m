% excute the job in dqshtc
DIR= '/scratch/yl148/PSC';
datadir=fullfile(DIR,'data');
subID=dir(datadir);
subID={subID.name};
subID=subID(3:end);
L=length(subID);

scriptdir =fullfile(DIR,'Scilpy/');
scriptdir1 =fullfile(scriptdir,'PSC_Pipeline/UK_Biobank/');

codedir = fullfile(DIR,'code4');

if exist(codedir)
   system(sprintf('rm %s/*',codedir));
end
system(sprintf('mkdir %s',codedir));


fid0 = fopen(fullfile(codedir,'All_step4.sh'),'w');
fprintf(fid0,'#!/bin/tcsh\n');
for i=1:L
    disp(L-i)
    sub_id = subID{i};
	temp=fullfile(datadir,sub_id,'dwi.nii.gz');
	temp1=fullfile(datadir,sub_id,'data.nii.gz');
	temp2=fullfile(datadir,sub_id,'nodif.nii.gz');
	if (~exist(temp)) & (~exist(temp1)) & (~exist(temp2))
	continue;
	end
	temp=fullfile(datadir,sub_id);
	temp0=dir(temp);
	temp0={temp0.name}';
	temp0=temp0(3:end);
	l00=length(temp0);
	temp=fullfile(datadir,sub_id,'diffusion');
	temp1=dir(temp);
	temp1={temp1.name}';
	temp1=temp1(3:end);
	l01=length(temp1);
	temp=fullfile(datadir,sub_id,'registration');
	temp1=dir(temp);
	temp1={temp1.name}';
	temp1=temp1(3:end);
	l02=length(temp1);
	temp=fullfile(datadir,sub_id,'structural');
	temp2=dir(temp);
	temp2={temp2.name}';
	temp2=temp2(3:end);
	l03=length(temp2);
	if (l01<37)|(l02~=3)|(l03~=19) 
	%continue;
	end
	
    fid = fopen(sprintf('%s/job_stg4_%s.pbs',codedir,subID{i}),'w');
    fprintf(fid, '#!/bin/bash\n');
    fprintf(fid,'#SBATCH --job-name=%s\n',subID{i});
    fprintf(fid, '#SBATCH --mem-per-cpu=80000m\n');
    fprintf(fid, '#SBATCH --time=10:00:00\n');
    %fprintf(fid,'#PBS -l nodes=1:rhel7:ppn=10 -l walltime=71:59:59,mem=80gb\n');
    %fprintf(fid,'#PBS -N Zhengwu_%s\n',subID{i});
    %fprintf(fid,'#PBS -j oe\n');
    %fprintf(fid, '# sub job for subject %s \n', sub_id);
    fprintf(fid,'module load GSL/2.4\n');
    fprintf(fid,'module load MRtrix/0.3.15\n');
    fprintf(fid,'module load FSL/5.0.10\n');
    fprintf(fid,'module load ANTs/2.1.0\n');
    %fprintf(fid,'module load gsl/1.16\n');
    %fprintf(fid,'module load mrtrix\n');
    %fprintf(fid,'module load FSL\n');
    %fprintf(fid,'module load ANTs/2.1.0\n');
    fprintf(fid,'module load FreeSurfer/6.0.0\n');
	%fprintf(fid,'module load freesurfer\n');
	fprintf(fid,'export PATH=/workspace/tli3/software/Anaconda2_for_scilpy2017/Anaconda2/bin:$PATH \n');
	fprintf(fid,'export PATH=%s/scripts/:${PATH} \n',scriptdir);
    fprintf(fid,'export PYTHONPATH=%s/ \n',scriptdir);
	fprintf(fid,'cd %s/%s \n',datadir,sub_id);
    %remove output1 and prepare for re-write
    fprintf(fid,'chmod 775 %s/TRACTOGRAPHY_Step2.sh \n',scriptdir1);
	fprintf(fid,'sh %s/TRACTOGRAPHY_Step2.sh \n',scriptdir1);
    %fprintf(fid, '# sub job for subject %s is done \n', sub_id);
    fprintf(fid, '# -------------------------   #');
    fclose(fid);	
	fprintf(fid0,'qsub job_stg4_%s.pbs\n',subID{i});
end

fclose(fid0);
