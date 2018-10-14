
function image = bcps_algorithm(vessel, t)
   
   vesselcgc = pbc_to_cgc(vessel);
   vesselbp = image_to_bitplane(vesselcgc);
   [noise,informative] = segmentation(vesselbp);
   
   [textB,conj_map] = group_text_into_block(t);
      
    vesselbp([noise],:,:) = embed_block_into_bp(textB, vesselbp(noise,:,:)); 
    %vesselbp([noise],:,:) = embed_block_into_bp(conj_map,vesselbp(noise,:,:));
    
    vesselcgc = bitplane_to_image(vesselbp);
    image = cgc_to_pbc(vesselcgc);
end