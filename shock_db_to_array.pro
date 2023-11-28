function shock_db_to_array
; Main structure is 'shocks'
;
; shocks.E### = event ID number
;
; shocks.###.Date_JD = JD datetime of the shock at Wind
; shocks.###.Date_YYYYMMDD = YYYYMMDD of the shock at Wind
; shocks.###.Time = time of arrival of the shock at Wind
; shocks.###.Shock_type = type of shock event
; shocks.###.Notes = Notes on the shock event (managed by this database)
; shocks.###.V_multi = mutliple spacecraft MEAN shock speed
; shocks.###.V_multi_std = multiple spacecraft standard deviation
; shocks.###.V_multi_NX = multiple spacecraft Nx
; shocks.###.V_multi_NX_std = multiple spacecraft Nx stddev
; shocks.###.V_multi_NY = multiple spacecraft NY
; shocks.###.V_multi_NY_std = multiple spacecraft NY stddev; 
; shocks.###.V_multi_NZ = multiple spacecraft NZ
; shocks.###.V_multi_NZ_std = multiple spacecraft NZ stddev
; shocks.###.V_multi_phi = multiple spacecraft phi value (calculated)
; shocks.###.V_multi_phi_stdev = multiple spacecraft phi value stddev (calculated)
; shocks.###.V_multi_theta = multiple spacecraft theta value (calculated)
; shocks.###.V_multi_theta_stdev = multiple spacecraft theta value stddev (calculated)
; shocks.###.V_single = single spacecraft shock velocity
; shocks.###.V_single_std = single spacecraft shock velocity stddev
; shocks.###.V_single_error = single spacecraft shock velocity error
; shocks.###.V_single_compress = single spacecraft compressability
; single.###.V_single_compress_error = single spacecraft compressability error
; shocks.###.V_single_theta_Bn = single spacecraft theta Bn
; shocks.###.V_single_theta_Bn_error = single spacecraft theta Bn error
; shocks.###.V_single_normtheta = single spacecraft normal vector theta
; shocks.###.V_single_normtheta_error = spacecraft normal vector theta error
; shocks.###.V_single_phi = single spacecraft normal vector phi
; shocks.###.V_single_phi_error = single spacecraft normal vector phi error
; shocks.###.Wi_X = median X position of Wind spacecraft
; shocks.###.Wi_Y = median Y position of Wind spacecraft
; shocks.###.Wi_Z = median Z position of Wind spacecraft
; shocks.###.St_tshift = Time shift of the Stereo-A spacecraft
; shocks.###.St_X = median X position of Stereo-A spacecraft
; shocks.###.St_Y = median Y position of Stereo-A spacecraft
; shocks.###.St_Z = median Z position of Stereo-A spacecraft
  
;NOTE: Requires remove function to run correctly in IDL, which is part
;of SSWIDL

; KEYWORDS:
;
;       none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;Restore the database
  database_filename = 'Single_and_Multi_SC_Shock_database.idl'
  restore,database_filename

  ;Start with empty arrays to populate
  ID = []
  Date_JD = []
  Date_YYYYMMDD = []
  Time = []
  Type = []
  Vm = []
  Vm_std = []
  Vm_NX = []
  Vm_NX_std = []
  Vm_NY = []
  Vm_NY_std = []
  Vm_NZ = []
  Vm_NZ_std = []
  Vm_phi = []
  Vm_phi_std = []
  Vm_theta = []
  Vm_theta_std = []
  Vs = []
  Vs_std = []
  Vs_error = []
  compress = []
  compress_error =  []
  theta_bn =  []
  theta_bn_error = []
  norm_theta = []
  norm_theta_error = []
  phi = []
  phi_error = []
  wi_x = []
  wi_y = []
  wi_z = []
  st_tshift = []
  st_x = []
  st_y = []
  st_z = []
  notes = []

  ;Start with getting all events in the database
  database_events = tag_names(shocks)

  ;Replace E in events and add to array
  foreach event, database_events do begin
      ID = [ID, event.replace('E', '')]
  endforeach

  ;Loop through stucture and build arrays 
  for i = 0, (n_elements(database_events)-1) do begin
     Date_JD = [Date_JD, shocks.(i).Date_JD]
     Date_YYYYMMDD = [Date_YYYYMMDD, shocks.(i).Date_YYYYMMDD]
     Time = [Time, shocks.(i).Time]
     Type = [Type, shocks.(i).Shock_Type]
     Vm = [Vm, shocks.(i).V_multi]
     Vm_std = [Vm_std, shocks.(i).V_multi_std]
     Vm_NX = [Vm_NX, shocks.(i).V_multi_NX]
     Vm_NX_std = [Vm_NX_std, shocks.(i).V_multi_NX_std]
     Vm_NY = [Vm_NY, shocks.(i).V_multi_NY]
     Vm_NY_std = [Vm_NY_std, shocks.(i).V_multi_NY_std]
     Vm_NZ = [Vm_NZ, shocks.(i).V_multi_NZ]
     Vm_NZ_std = [Vm_NZ_std, shocks.(i).V_multi_NZ_std]
     Vm_phi = [Vm_phi, shocks.(i).V_multi_phi]
     Vm_phi_std = [Vm_phi_std, shocks.(i).V_multi_phi_std]
     Vm_theta = [Vm_theta, shocks.(i).V_multi_theta]
     Vm_theta_std = [Vm_theta_std, shocks.(i).V_multi_theta_std]
     Vs = [Vs, shocks.(i).V_single]
     Vs_std = [Vs_std, shocks.(i).V_single_std]
     Vs_error = [Vs_error, shocks.(i).V_single_error]
     compress = [compress, shocks.(i).V_single_compress]
     compress_error =  [compress_error, shocks.(i).V_single_compress_error]
     theta_bn =  [theta_bn, shocks.(i).V_single_theta_bn]
     theta_bn_error = [theta_bn_error, shocks.(i).V_single_theta_bn_error]
     norm_theta = [norm_theta, shocks.(i).V_single_normtheta]
     norm_theta_error = [norm_theta_error, shocks.(i).V_single_normtheta_error]
     phi = [phi, shocks.(i).V_single_phi ]
     phi_error = [phi_error, shocks.(i).V_single_phi_error]
     wi_x = [wi_x, shocks.(i).Wi_X]
     wi_y = [wi_y, shocks.(i).Wi_Y]
     wi_z = [wi_z, shocks.(i).Wi_Z]
     st_tshift = [st_tshift, shocks.(i).St_tshift]
     st_x = [st_x, shocks.(i).St_X]
     st_y = [st_y, shocks.(i).St_Y]
     st_z = [st_z, shocks.(i).St_Z]
     notes = [notes, shocks.(i).Notes]
  endfor
  
  shock_array = create_struct('ID', ID, 'Date_JD', Date_JD, 'Date_YYYYMMDD', Date_YYYYMMDD, 'Time', Time, 'Shock_Type', type, 'V_multi', Vm, 'V_multi_std', Vm_std, 'V_multi_NX', Vm_NX, 'V_multi_NX_std', Vm_NX_std, 'V_multi_NY', Vm_NY, 'V_multi_NY_std', Vm_NY_std, 'V_multi_NZ', Vm_Nz, 'Vm_multi_NZ_std', Vm_NZ_std, 'V_multi_phi', Vm_phi, 'V_multi_phi_std', Vm_phi_std, 'V_mutli_theta', Vm_theta, 'V_multi_theta_std', Vm_theta_std, 'V_single', Vs, 'V_single_std', Vs_std, 'V_single_error', Vs_error, 'V_single_compress', compress, 'V_single_compress_error',compress_error, 'V_single_theta_Bn',theta_bn,  'V_single_theta_Bn_error', theta_bn_error, 'V_single_normtheta', norm_theta, 'V_single_normtheta_error', norm_theta_error, 'V_single_phi', phi, 'V_single_phi_error', phi_error, 'Wi_X', wi_x, 'Wi_Y', wi_y, 'Wi_Z', wi_z, 'St_tshift', st_tshift, 'St_X', st_x, 'St_Y', st_y, 'St_Z', st_z, 'Notes', notes)  
  
  return, shock_array
end
