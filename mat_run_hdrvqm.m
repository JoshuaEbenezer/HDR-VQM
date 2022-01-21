clear
video_dir = '/media/josh-admin/seagate/fall2021_hdr_upscaled_yuv';
out_dir = './features/';
T = readtable('/home/josh-admin/hdr/qa/hdr_chipqa/fall2021_yuv_rw_info.csv');
rng(0,'twister');

disp(T)
all_yuv_names = T.yuv;
ref_yuv_names = all_yuv_names((contains(all_yuv_names,'ref')));
framenums = T.framenos

disp(ref_yuv_names)

width = 3840;
height = 2160;

for yuv_index = 1:length(all_yuv_names)
    
    
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
    

    
    
    yuv_framenums = framenums(yuv_index)
    for framenum=1:yuv_framenums
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

         

        error_video_hdrvqm(:,:,framenum)= subband_errors(((((double(pu_encode_new((refY_linear))))))),(((((double(pu_encode_new((disY_linear)))))))),...
                5,4);
            
    end
  
    HDRVQM = st_pool(st_pool(error_video_hdrvqm,0.5),0.5);
    clear error_video_hdrvqm;
    featMap.distorted_name = string(yuv_name);
    featMap.hdrvqm= HDRVQM;
    save(outname,'featMap');

end

quit
