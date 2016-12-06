study='IEHFMRI';
% subj_nums=[4 6:8 11:14 16:22 24 25]; % all subjects leaving out 5 which has to be remodeled
subj_nums=[5];
subjs={};sessions={};
for s=1:length(subj_nums)
    subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',subj_nums(s))];
end


for thissub=1:length(subjs)
	betanames={};
	cd(fullfile('/younglab/studies',study,'duration60secs_behavioral'));

	for thisrun=1:8
		fname=[subjs{thissub} '.ieh.' num2str(thisrun) '.mat'];
		f=load(fname);
		names=cell(length(f.spm_inputs_itemwise),1);
		for thisitem=1:length(f.spm_inputs_itemwise)
			newname=[sprintf('%02d',thisitem) '_' f.spm_inputs_itemwise(thisitem).name(end)];
			betanames{end+1}=[newname '.nii'];
		end
	end

	cd(fullfile('/younglab/studies',study,subjs{thissub},'results/ieh_results_itemwise_normed'));
	betadir=dir('beta_*.nii');
	for thisbeta=1:length(betanames)
		movefile(betadir(thisbeta).name,['beta_item_' sprintf('%03d',thisbeta) '_' betanames{thisbeta}]);
	end

end

% condnames={'estim' 'imagn' 'journ' 'memry'};
% rootdir='/younglab/studies';
% resdir='ieh_results_itemwise_normed';
% subjIDs=subjs;
% roiname='Hipp_R'

% for thissub=1:length(subjs)
% 	cd(fullfile('/younglab/studies',study,subjs{thissub},'results/ieh_results_itemwise_normed'));
% 	betadir=dir('beta_item*.nii');
% 	for thisbeta=1:length(betadir)
% 		item_tag=betadir(thisbeta).name(15:16);
% 		if strcmp(item_tag(2),'_')
% 			item_tag=sprintf('%02d',str2num(item_tag(1)));
% 			newname=[betadir(thisbeta).name(1:14) item_tag betadir(thisbeta).name(16:end)];
% 			movefile(betadir(thisbeta).name,newname);
% 		end
% 	end
% end