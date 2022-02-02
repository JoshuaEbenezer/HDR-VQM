clear
video_dir = '/media/josh-admin/seagate/fall2021_hdr_upscaled_yuv';
out_dir = './features/';
T = readtable('/home/josh-admin/code/hdr/qa/hdr_chipqa/fall2021_yuv_rw_info.csv');
rng(0,'twister');

disp(T)
all_yuv_names = T.yuv;
ref_yuv_names = all_yuv_names((contains(all_yuv_names,'ref')));
framenums = T.framenos
fps_list = T.fps

disp(ref_yuv_names)

width = 3840;
height = 2160;


tbd_yuv_indices = []
for yuv_index = 1:length(all_yuv_names)
	yuv_name = char(all_yuv_names(yuv_index));
	outname = fullfile(out_dir,strcat(yuv_name(1:end-4),'.mat'));
	if(isfile(outname))
		continue
	else
		tbd_yuv_indices = [tbd_yuv_indices,yuv_index]
	end
end

for tbd_yuv_index = 1:length(tbd_yuv_indices)

	yuv_index = tbd_yuv_indices(tbd_yuv_index);

	%set the default parameters, run the config file
	cfg_hdrvqm = config_hdrvqm()
	yuv_name = char(all_yuv_names(yuv_index));
	TF = contains(yuv_name,'ref');
	if(TF)
		continue
	end

	outname = fullfile(out_dir,strcat(yuv_name(1:end-4),'.mat'));

	% get reference
	splits = strsplit(yuv_name,'_');
	content = splits(3);
	ref_name = char(all_yuv_names((contains(all_yuv_names,strcat(char('4k_ref_'),content)))));
	disp(ref_name);
	ref_upscaled_name = strcat(ref_name(1:end-4),char('_upscaled.yuv'));
	disp(ref_upscaled_name);



	dis_upscaled_name = strcat(yuv_name(1:end-4),char('_upscaled.yuv'));
	disp(dis_upscaled_name);


	full_ref_yuv_name = fullfile(video_dir,ref_upscaled_name);    
	disp(full_ref_yuv_name);
	full_yuv_name = fullfile(video_dir,dis_upscaled_name);
	disp(full_yuv_name);

	%no. of rames to fixate
	cfg_hdrvqm.frame_rate = fps_list(yuv_index)
	
	cfg_hdrvqm.fixation_time = .6; %600 ms for distorted videos
	cfg_hdrvqm.n_frames_fixate = ceil(cfg_hdrvqm.frame_rate *  cfg_hdrvqm.fixation_time);
%	error_video_hdrvqm = zeros(512,896,cfg_hdrvqm.n_frames_fixate)

	yuv_framenums = framenums(yuv_index)
	ST_v_ts = []
	error_video_hdrvqm = []
%	ST_v_ts = zeros(512,896,floor(yuv_framenums/cfg_hdrvqm.n_frames_fixate))


	indx = 1;
	count = 1;
	for framenum=1:yuv_framenums
		disp(framenum)
		[refY,~,~,status_ref] = yuv_import(full_ref_yuv_name,[width,height],framenum,'YUV420_16');
		refY_linear = eotf_pq(refY);
		if(status_ref==0)
			disp(strcat("Error reading frame in ",full_ref_yuv_name));
		end

		[disY,~,~,status_dis] = yuv_import(full_yuv_name,[width,height],framenum,'YUV420_16');
		if(status_dis==0)
			disp(strcat("Error reading frame in ",full_yuv_name));
		end
		disY_linear = eotf_pq(disY);



		error_video_hdrvqm(:,:,count)= subband_errors(((((double(pu_encode_new((refY_linear))))))),(((((double(pu_encode_new((disY_linear)))))))),...
			5,4);

		if(count==cfg_hdrvqm.n_frames_fixate)
			ST_v_ts(:,:,indx) = hdrvqm_short_term_temporal_pooling(error_video_hdrvqm,cfg_hdrvqm);
			indx = indx + 1;

			count = 1;
			clear error_video_hdrvqm;
		end
		count = count+1;

	end

	[r,c,t] = size(ST_v_ts);
	ST_v_ts = reshape(ST_v_ts,r*c,t);
	HDRVQM= st_pool(st_pool(ST_v_ts,cfg_hdrvqm.perc),cfg_hdrvqm.perc);

	featMap = struct
	featMap.distorted_name = string(yuv_name);
	featMap.hdrvqm= HDRVQM;
	save(outname,'featMap');

end

quit
