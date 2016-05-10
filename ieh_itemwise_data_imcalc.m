function ieh_itemwise_data_imcalc(roinames,is_subjectwise)
% ieh_itemwise_data_imcalc:
% performs same function as ieh_itemwise_data, using imcalc to mask beta images
%is_subjectwise is 1 if subject-specific ROI, 0 if group ROI
%roinames: cell array, e.g. {'RTPJ'}

    study='IEHFMRI';
    subj_nums=[4:8 11:14 16:22 24 25]; 
    subjs={};sessions={};
    for s=1:length(subj_nums)
        subjs{end+1}=['YOU_IEHFMRI_1' sprintf('%02d',subj_nums(s))];
    end


    condnames={'estim' 'imagn' 'journ' 'memry'};
    %1->1
    %2->4
    %3->2
    %4->3
    rootdir='/younglab/studies';
    resdir='ieh_results_itemwise_normed';
    subjIDs=subjs;
    % roiname='Retrosplenial_R';
    neuro_total=[];
    mkdir(fullfile(rootdir,study,'logs'));
    diary(fullfile(rootdir,study,'logs',['ieh_itemwise_data_imcalc_' date '.txt']));

    for thisroi=1:length(roinames)
        roiname=roinames{thisroi};
        all_sub_info=[];
        all_cond_info=[];
        all_neural_info=[];
        for thissub=1:length(subjs)
        	disp(['Processing subject ' subjs{thissub}]);

        	for thiscond=1:length(condnames)
                neuralcolumn=[];
        		disp(['Processing condition ' condnames{thiscond}]);
        		cd(fullfile('/younglab/studies',study,subjs{thissub},'results/ieh_results_itemwise_normed'));
        		betadir=dir(['beta_item*' num2str(thiscond) '.nii']);
        		betafiles=cell(length(betadir),1);

        		for i=1:length(betafiles)
        	        betafiles{i} = betadir(i).name;
        	    end
        	    disp('Loading beta files...')
        	    subimg    = spm_vol([repmat([fullfile(rootdir,study,subjIDs{thissub},'results',[resdir '/'])],length(betafiles),1) char(betafiles) repmat(',1',length(betafiles),1)]); %spm_vol reads header info
        	    [Y,XYZ]   = spm_read_vols(subimg);clear betadir XYZ %read volumes

        	    disp('Getting mask image...')
        	    prev_dir=pwd;
                if ~is_subjectwise
        	       cd(fullfile(rootdir,study,'ROI'));
                else
                    cd(fullfile(rootdir,study,subjIDs{thissub},'roi'));
                end
            	roidir=dir(['*' roiname '*img']);
            	if isempty(roidir)
                disp(['No ' roiname ' for subject ' subjIDs{thissub} '; continuing to next subject']);
                continue
            	end
            	disp('Processing mask...')
            	mask_img=fullfile(pwd,roidir(1).name);
                disp(['Mask file: ' mask_img]);
                cd(fullfile('/younglab/studies',study,subjs{thissub},'results/ieh_results_itemwise_normed'));
                for i=1:length(betafiles)
                    Vi={betafiles{i} mask_img};
                    Vi=char(Vi);
                    Vi=spm_vol(Vi);
                    Vo='REMOVETHIS.img';
                    Q=spm_imcalc(Vi,Vo,'i1.*i2');

                    Q=spm_read_vols(Q);
                    Q_inds=find(Q~=0);
                    item_mean=nanmean(Q(Q_inds));

                    neuralcolumn=[neuralcolumn; item_mean];

                    delete('REMOVETHIS.img');delete('REMOVETHIS.hdr');
                end


                subjcolumn=[repmat([subjIDs{thissub}],length(betafiles),1)];
                condcolumn=[repmat([condnames{thiscond}],length(betafiles),1)];

                all_sub_info=[all_sub_info; subjcolumn];
                all_cond_info=[all_cond_info; condcolumn];
                all_neural_info=[all_neural_info; neuralcolumn];
        	end%end cond loop
        end%end subject loop

    neuro_total=[neuro_total all_neural_info];
    disp(['Finished with roi ' roiname])
    cd(fullfile(rootdir,study,'results'));
    save(['all_itemwise_' roiname '.mat'],'all_sub_info','all_cond_info','all_neural_info','roinames');    
    end %end roi loop
    % save('all_itemwise_allrois.mat','neuro_total','roinames');
    diary off;
end