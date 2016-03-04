function DIS_mvpa()

%April 122, for DIS


savedirectory = '/younglab/studies/DIS_MVPA/MVPA_data_raw_SAX_DIS_03_Jorie'
mkdir(savedirectory,'MVPA_images');

roiFiles = {'RTPJ'}; %{'RTPJ','LTPJ','PC','DMPFC'}
group = 0;
group_loc = '/younglab/roi_library/newrois';
parametric = 1; 

experiments=struct(...
    'name','DIS',...
    'pwd1','/younglab/studies/DIS_MVPA/',...   %folder with participants 
    'pwd2','results/DIS_results_normed_Jorie',...   %inside each participant, path to .spm   
    'data',{{'SAX_DIS_03'}});
%   'data',{{'SAX_DIS_03',	'SAX_DIS_04','SAX_DIS_05',	'SAX_DIS_06',	'SAX_DIS_07',	'SAX_DIS_08',	'SAX_DIS_09',...
%       'SAX_DIS_10',	'SAX_DIS_11',	'SAX_DIS_12',	'SAX_DIS_13',	'SAX_DIS_14', 'SAX_DIS_27', 'SAX_DIS_28',...
%       'SAX_DIS_32', 'SAX_DIS_33','SAX_DIS_34','SAX_DIS_35'}}); % NT total = 18
 %%%% for whatever reason, Jorie's script also included SAX_DIS_25, whose
 %%%% data we're missing; also SAX_DIS_33 & SAX_DIS_35 do not have RTPJ ROI

%Different Populations

% % NT 'data',{{'SAX_DIS_03',	'SAX_DIS_04','SAX_DIS_05',	'SAX_DIS_06',	'SAX_DIS_07',	'SAX_DIS_08',	'SAX_DIS_09',...
%       'SAX_DIS_10',	'SAX_DIS_11',	'SAX_DIS_12',	'SAX_DIS_13',	'SAX_DIS_14', 'SAX_DIS_25','SAX_DIS_27', 'SAX_DIS_28',...
%       'SAX_DIS_32', 'SAX_DIS_33','SAX_DIS_34','SAX_DIS_35'}});

%MISSING NEUTRAL  'SAX_DIS_01', 'SAX_DIS_02'

%ASD     'data',{{'SAX_DIS_15',	'SAX_DIS_16',	'SAX_DIS_17',	'SAX_DIS_18',	'SAX_DIS_19',	'SAX_DIS_20','SAX_DIS_22','SAX_DIS_23',	'SAX_DIS_24','SAX_DIS_29',	'SAX_DIS_30',	'SAX_DIS_31', }});

 
partition_names={'ODD_','EVEN_'}; % {'Odd ', 'Even '}

 condition_names_all={{'accidental-harm','intent-harm'}};
%  
%  { {'moral','neutral'},... 
%      {'accidental-harm','intent-harm','accidental-neutral','intent-neutral'},... 
%      {'accidental-harm','intent-harm','accidental-disgust','intent-digust' },...
%      {'accidental-disgust','intent-digust','accidental-neutral','intent-neutral'},...
%      {'harml','disgust'},...
%      {'harml','disgust', 'neutral'}}; % , ...
  %   {'accidental-harm','accidental-disgust'}, ...
  %   {'physical_harm','psych_harm'},...
   %  {'incest-disgust','pathogen-disgust'},...
%    
  %   {'accidental-neut','intent-neut'},...
 %    {'accidental-noneut','intent-noneut'}, ...
  %   {'accidental-disgust','intent-digust'}, ...
   %  {'accidental-disgust','intent-digust', 'accidental-neutral','intent-neutral'}...
  %   {'intent-harm','intent-digust'},...
  %   {'physical_harm','psych_harm'},...
  %   {'harml','disgust','neutral'},...
   %  {'intent-harm','intent-digust', 'intent-neutral'},...
   %  {'accidental-harm','accidental-disgust','accidental-neutral'}};

for i=1:length(roiFiles)
    roin = roiFiles{i};
    roinum = i;
    analyMVPA_general(roin, experiments,partition_names,condition_names_all,savedirectory, roinum, group, group_loc,parametric);
end