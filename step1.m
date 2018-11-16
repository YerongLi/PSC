% excute the job in dqshtc

DIR= '/home/yl148/PSC/';
%datadir=fullfile(DIR,'data')
datadir=fullfile(DIR,'data');
%datadir=fullfile(DIR,'data2');
subID=dir(datadir);
subID={subID.name};
subID=subID(3:end);
L=length(subID);

scriptdir =fullfile(DIR,'Scilpy/');
scriptdir1 =fullfile(scriptdir,'PSC_Pipeline/UK_Biobank/');

codedir = fullfile(DIR,'code');
%codedir = fullfile(DIR,'code1');

if exist(codedir)
   delete(fullfile(codedir,'/*'));
end
mkdir(codedir)

fid0 = fopen(fullfile(codedir,'All_step1.sh'),'w');
fprintf(fid0,'#!/bin/tcsh\n');

disp(L)
for i=1:L
    sub_id = subID{i};
	temp=fullfile(datadir,sub_id,'AP.nii.gz');     % one of them should work
	temp1=fullfile(datadir,sub_id,'data.nii.gz');  % one of them should work
	temp2=fullfile(datadir,sub_id,'nodif.nii.gz'); % one of them should work
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
	if (l00==17)&(l01==8)&(l02==3)&(l03==2) 
	continue;
	end
	
    fid = fopen(sprintf('%s/jobsubmission_stg1_%s.pbs',codedir,subID{i}),'w');
    %fprintf(fid,'#PBS -l nodes=1:rhel7:ppn=1 -l walltime=23:59:59,mem=8gb\n');
    %%fprintf(fid,'#PBS -l nodes=1:rhel7:ppn=1 -l walltime=23:59:59,mem=16gb\n');
    fprintf(fid, '#!/bin/bash\n');
    fprintf(fid, '#SBATCH --ntasks=1\n');
    fprintf(fid, '#SBATCH --mem-per-cpu=16000m\n');
    fprintf(fid, '#SBATCH --time=10:00:00\n');
    fprintf(fid, '#SBATCH --mail-type=ALL\n');

    %%fprintf(fid,'#PBS -N Zhengwu_%s\n',subID{i});
    fprintf(fid,'#SBATCH --job-name=%s\n',subID{i});
    %%fprintf(fid,'#PBS -o Zhengwu_%s.out\n',subID{i});
    fprintf(fid,'#SBATCH -o PSC%s.out\n',subID{i});
    fprintf(fid,'#SBATCH -e err%s\n',subID{i});
    %%fprintf(fid,'#PBS -j oe\n');
    fprintf(fid, '# sub job for subject %s \n', sub_id);
    fprintf(fid,'module load GCC/6.4.0  OpenMPI/2.1.3 MRtrix/0.3.15 GSL/2.4  ANTs/2.1.0 FreeSurfer/6.0.0 FSL\n');
    fprintf(fid,'module load Anaconda2/5.0.0\n');

    %%fprintf(fid,'module load mrtrix\n');
    %%fprintf(fid,'module load FSL\n');
    %%fprintf(fid,'module load ANTs/2.1.0\n');
    %%fprintf(fid,'setenv PATH /workspace/tli3/software/Anaconda2_for_scilpy2017/Anaconda2/bin:$PATH \n');
    fprintf(fid,'export PATH=/home/yl148/PSC/Scilpy/scripts/:$PATH \n',scriptdir);
    fprintf(fid,'export PYTHONPATH=%s \n',scriptdir);
    fprintf(fid,'cd %s/%s \n',datadir,sub_id);
    %remove output1 and prepare for re-write
    fprintf(fid,'chmod 775 %s/PREPROCESS_Step1_Registration.sh \n',scriptdir1);
	
	fprintf(fid,'mv dwi.nii.gz data.nii.gz \n');
	fprintf(fid,'mv nodif.nii.gz t1.nii.gz \n');
	fprintf(fid,'mv bvecs0 bvecs \n');
	fprintf(fid,'mv bvals0 bvals \n');
	
	
    fprintf(fid,'sh %s/PREPROCESS_Step1_Registration.sh \n',scriptdir1);
    fprintf(fid, '# sub job for subject %s is done \n', sub_id);
    fprintf(fid, '# -------------------------   #');
    fclose(fid);	
	fprintf(fid0,'sbatch jobsubmission_stg1_%s.pbs\n',subID{i});
end

fclose(fid0);
