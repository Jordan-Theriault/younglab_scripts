function searchlight_all_regress_pleiades(rootdir,study,subj_tag,resdir,sub_nums,cond_in,sph,B_in,outtag)
% searchlight_all_regress(rootdir,study,subj_tag,resdir,sub_nums,conditions,sph,B_in,outtag):
% - performs searchlight RSA, using 1 to n matrix regressors to model the empirical neural similarities.
% 
% Parameters:
% - rootdir:
% - study: name of study folder (string)
% - subj_tag: prefix to subject names (string) e.g. SAX_DIS
% - resdir: results directory (string) e.g. tom_localizer_results_normed
% - sub_nums: subject numbers (array)
% - cond_in: array indicating first and last indices of beta files to load
% Ex. cond_in = [1:48] will load beta_item_01.nii to beta_item_48.nii
% - sph: sphere size (numerical); 3 is recommended
% - B_in: cell array of strings, each of which denotes a regressor matrix to load
% The nth matrix must be in the format "behav_matrix_*.mat" where * is B_in{n}
% and must be stored in a variable within that .mat named behav_matrix.
% These must be located in your study's behavioural directory.
% - outtag: string to label this analysis. Must start with '_'
%
% Output:
% - bigmat*.mat: per-voxel item crosscorrelation values across the brain
% - corrs*.mat: regression weights for each regressor, in each sphere
% - spear*.mat: Spearman correlations of every predictor with the vector of neural similarities
% - [searchlight images]: .nii files prepended with "RSA_searchlight_regress", in resdir
% 
% Notes:
% - greymattermask2 and voxel_order2 are designed for studies in 3x3x3mm space.
% - in corrs*.mat and spear*.mat, the LAST value represents the constant (intercept) regressor.

	addpath('/home/younglw/scripts/combinator')
	addpath(genpath('/usr/public/spm/spm12'));
	subjIDs={};
	for sub=1:length(sub_nums)
		subjIDs{end+1}=sprintf([subj_tag '_' '%02d'],sub_nums(sub));
    end

% for psych-phys on pleiades: rootdir = /home/younglw/server/englewood/mnt/englewood/data
	spheresize=(2*sph)-1;
	%notice that the number of voxels in your sphere increases exponentially with sphere size.
	%for example, sph=2 corresponds to 7 shifts. sph=3 : 81 shifts. sph=4 : 275 shifts. sph=5 : 637 shifts.
	%reminder to be conservative about choosing sphere size
	move_coords=(6*(spheresize-2)^2)+(spheresize-2)^3; %the number of unique shift combinations to obtain coordinates w/in sphere
	v=-(sph-2):(sph-2);
	vindices_1=combinator(length(v),3,'p','r');
	vindices_2=combinator(length(v),2,'p','r');
	c1=v(vindices_1); c2=v(vindices_2);
	edge=repmat(sph-1,length(c2),1); %vector of repeated edge number
	coords=[c1; [edge c2]; [-edge c2]; [c2 edge]; [c2 -edge]; [c2(:,1) edge c2(:,2)]; [c2(:,1) -edge c2(:,2)]];
	%what this does: all permutations without any 'edge numbers' + perms with an edge number in position x, y, or z respectively 
	%edge number = sph-1 or -(sph-1).
    save(fullfile(rootdir,study,'coords.mat'),'coords');
    
    disp(['Root directory: ' rootdir]);
    disp(['Subjects: ' subjIDs]);
    disp(['Study: ' study]);
    disp(['Results directory: ' resdir]);
    disp(['ID tag: ' outtag]);
    % disp(['Design matrices: ' b1 ' ' b2 ' const']);


	cd('/home/younglw/scripts/');
	load voxel_order2; 
    load greymattermask2;

	for subj=1:length(subjIDs) %grabbing beta images

		disp(['Processing subject ' subjIDs{subj} '.']);
		tic
		B=[];
		for b=1:length(B_in)
			try
				load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' B_in{b} '.mat']));
		        disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' B_in{b} '.mat']));
		        behav_matrix=sim2tril(behav_matrix);
				B=[B behav_matrix];
				clear behav_matrix;
			catch
				load(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' B_in{b} '.mat']));
		        disp(fullfile(rootdir, study, 'behavioural',['behav_matrix_' subjIDs{subj} '_' B_in{b} '.mat']));
		        behav_matrix=sim2tril(behav_matrix);
				B=[B behav_matrix];
				clear behav_matrix;
			end
		end

	    cd(fullfile(rootdir,study,subjIDs{subj},'results', resdir));


	    c1=cond_in(1);
	    conditions=length(cond_in);

	    betadir = dir('beta_item*nii');betafiles=cell(conditions,1);
	    for i=1:conditions
	        betafiles{i} = betadir((i-1)+c1).name;
	    end
	    disp('Loading beta files...')
	    subimg    = spm_vol([repmat([fullfile(rootdir,study,subjIDs{subj},'results',[resdir '/'])],conditions,1) char(betafiles) repmat(',1',conditions,1)]); %spm_vol reads header info
	    [Y,XYZ]   = spm_read_vols(subimg);clear betadir betafiles XYZ %read volumes

	    disp(['Processing correlations...'])
	    triangle = ((conditions^2)/2)-(conditions/2);
	    bigmat = zeros(length(greymattermask2),triangle);
	    corrs  = zeros(length(greymattermask2),(size(B,2)+1)); 
	    spear=[];
	    for i = 1:length(greymattermask2)% for each voxel
	        sphere      = repmat(voxel_order2(greymattermask2(i),:),length(coords),1) + coords; 
	        spherebetas = zeros(length(coords),conditions);
	        for icoords = 1:length(coords) % get beta values for sphere voxels
                try
                    spherebetas(icoords,:) = Y(sphere(icoords,1), sphere(icoords,2), sphere(icoords,3), :);
                catch
                    continue
                end
	        end
	        goodrows = find(isnan(spherebetas(:,1)) == 0);
	        if length(goodrows) > 9 % if there are at least 10 good voxels in this sphere
	            simmat      = corrcoef(spherebetas(goodrows,:));% item similarities for this subject
	            temp        = tril(simmat,-1); % tril() gets lower triangle of matrix
	            size(temp)
	            size(temp(temp~=0)')
	            size(bigmat(i,:))
	            bigmat(i,:) = temp(temp~=0)';% we now have a triangle x 1 matrix

	            % temp        = corrcoef( behav_matrix , bigmat(i,:)' ); %correlation with behavioral matrix
	            predictors = horzcat(ones(size(B,1),1),B);
	            weights = regress(bigmat(i,:)',predictors);
	            weights=weights';

	            % corrs(i)    = temp(2,1); %save a correlation value for this voxel
	            corrs(i,:)=[weights(2:end) weights(1)];

	            thisspear = corr([bigmat(i,:)' predictors],'type','Spearman');
	            thisspear=thisspear(1,:); %only grab correlations of empirical data with predictors
	            thisspear=[thisspear(2:end) thisspear(1)];
	            spear=[spear;thisspear];


	        end
	    end
	    % clear temp simmat weights predictors thisspear

	    save(['bigmat_regression' outtag '.mat'], 'bigmat');
	    save (['corrs_regression' outtag '.mat'], 'corrs');
	    save (['spearman_regression' outtag '.mat'], 'spear');

	    disp('Correlations saved.');

	    for b=1:(length(B_in)+1)
		    corrmap(b).map  = zeros(size(Y(:,:,:,1))); 
	   	end

        % clear Y;

        for b=1:(length(B_in)+1)

		    for i=1:length(greymattermask2) 

	            corrmap(b).map(voxel_order2(greymattermask2(i),1),...
	                    voxel_order2(greymattermask2(i),2),...
	                    voxel_order2(greymattermask2(i),3)) = corrs(i,b);
		    end
		end
	    disp('Creating template...');

	    template_dir=dir('beta_*nii');
	    template       = spm_vol([fullfile(rootdir,study,subjIDs{subj},'results', resdir,template_dir(1).name) ',1']);

	    for b=1:length(B_in)
		    template.fname = ['RSA_searchlight_regress_' B_in{b} outtag '.img']; 
		    spm_write_vol(template,corrmap(b).map);
		end
		template.fname = ['RSA_searchlight_regress_const_' outtag '.img']; spm_write_vol(template,corrmap(length(B_in)+1).map);

	    % clear corrs meantril corrmap template spear
	    disp(['Subject ' subjIDs{subj} ' complete.'])
	    toc 
	end % subject list
end %end searchlight_all