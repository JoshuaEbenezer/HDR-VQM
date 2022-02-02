% Configuration file for Default values in HDR-VQM
%see ReadMe file for full description of the following options/parameters
function cfg_hdrvqm= config_hdrvqm()


	%supported formats are hdr and exr (default)
	%cfg_hdrvqm.format = ('.exr');

	%image or video
	cfg_hdrvqm.data = 'video';

	%whether to adapt to display, default no processing applied
	cfg_hdrvqm.do_adapt = 'none';

	%Matlab parallel environment, true by default
	cfg_hdrvqm.do_parallel_loop = 1;

	%Percentage for pooling, 30% by deafult 
	cfg_hdrvqm.perc = 0.3;

	%display parameters
	cfg_hdrvqm.rows_display = 3840;
	cfg_hdrvqm.columns_display = 2160;
	cfg_hdrvqm.area_display = 11967.3309; %in cm^2 
	cfg_hdrvqm.max_display = 1000; %cd/m^2 
	cfg_hdrvqm.min_display = 0.0001; %black level


	%viewing distance 
	cfg_hdrvqm.viewing_distance = 124.206; %in cm, approx. 3 times SIM2 height

	%compute block size automatically
	cfg_hdrvqm.bsize_temp = (tan(2*pi/180) * cfg_hdrvqm.viewing_distance * sqrt(cfg_hdrvqm.rows_display*cfg_hdrvqm.columns_display/cfg_hdrvqm.area_display))/2;
	i = 2:10;
	[v,p]=min(abs(cfg_hdrvqm.bsize_temp - 2.^i));
	cfg_hdrvqm.bsize = 2^(p+1); %block size rounded to power of 2

	%no. of rames to fixate
	cfg_hdrvqm.frame_rate = 25;
	cfg_hdrvqm.fixation_time = .6; %600 ms for distorted videos
	cfg_hdrvqm.n_frames_fixate = ceil(cfg_hdrvqm.frame_rate *  cfg_hdrvqm.fixation_time);

	%whether to use color for processing
	%not enabled in HDR-VQM (version 1)

	cfg_hdrvqm.do_color = 0;

	%scales and orientations for gabor decomposition
	cfg_hdrvqm.n_scale = 5;
	cfg_hdrvqm.n_orient = 4;

	%setting for dual modulation algorithm
	%cfg_hdrvqm.scaling = 'auto';
	%cfg_hdrvqm.psf_file = 'default';
end
