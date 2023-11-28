PRO shock_db_compiler

; Main structure is 'shocks'
;
; shocks.E### = event ID number
;
; shocks.###.Shock_Type = type of shock event
; shocks.###.notes = Notes on the shock event (managed by this database)
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

;Shocks to be added to db
shock_db_eventlist = ['692','693','696','698','699','705','706','708','709','716','718','719','721','722','727','728','729','732','733','734','735','744','747','754','758','759','760','761','769','774','775', '777', '778','779','780','781','787','788','789','790','791','792','794','795','802','849','852','854','858','859','860', '871', '872', '873', '874', '876', '877','878']

;Single and multi=spacecraft file paths
s_file = '/crater/projects/shockdb/shocks/shockdb/shockdb_wi.idl'
multi_file_path = '/crater/projects/structures/l1_formations'

; Set the database structure name
database_filename = 'Single_and_Multi_SC_Shock_database.idl'

;delete database if it exists
if file_test(database_filename) eq 1 then begin
   file_delete, database_filename
endif 

;Set variable to say to create new structure
test_for_new_database = 1

foreach event, shock_db_eventlist do begin
   print, 'Adding event: '+event

   ;restore the single spacecraft file
    restore, s_file
    
   ;Create holder list of all the catalog shocks
   event_list = shockdb.events

   ;Convert the event number to integer and get indexed array of correct data
   event_number = uint(event)
   event_data = event_list[event_number]

   ;Grab the correct single spacecraft data
   new_type = create_struct('Shock_Type', event_data.shock_type)
   new_Vs = create_struct('V_single',event_data.RH08.shock_speed.avg)
   new_Vs_std =  create_struct('V_single_std',event_data.RH08.shock_speed.dev)
   new_compress = create_struct('V_single_compress',event_data.RH08.compression.avg)
   new_compress_error = create_struct('V_single_compress_error',event_data.RH08.compression.err)
   new_theta_Bn = create_struct('V_single_theta_Bn',event_data.RH08.theta_bn.avg)
   new_theta_Bn_error = create_struct('V_single_theta_Bn_error',event_data.RH08.theta_bn.err)
   new_normtheta = create_struct('V_single_normtheta',event_data.RH08.norm_theta.avg)
   new_normtheta_error = create_struct('V_single_normtheta_error',event_data.RH08.norm_theta.err)
   new_normphi = create_struct('V_single_phi',event_data.RH08.norm_phi.avg)
   new_normphi_error = create_struct('V_single_phi_error',event_data.RH08.norm_phi.err)

   ;Renormalized uncertainty for single error
   basic_Vs_error = event_data.RH08.shock_speed.err
   chi_sq = event_data.RH08.CHISQMIN
   dof = event_data.RH08.DOF
   new_Vs_error = create_struct('V_single_error',(basic_Vs_error*dof)/(chi_sq))

   ;Arrival time data from Wind
   new_Date_JD = create_struct('Date_JD', event_data.arrival.JD)
   new_Time = create_struct('Time', round(event_data.arrival.UT))
   ;Build YYYY MM DD format and add
   new_Year = strtrim(round(event_data.arrival.year),1)
   new_Month = strtrim(round(event_data.arrival.month),1)
   if strlen(new_Month) lt 2 then new_Month = '0'+new_Month
   new_Day = strtrim(round(event_data.arrival.day),1)
   if strlen(new_Day) lt 2 then new_Day = '0'+new_Day
   build_YYYYMMDD = new_Year+new_Month+new_Day
   new_Date_YYYYMMDD = create_struct('Date_YYYYMMDD', build_YYYYMMDD)

   ;Search for the multi-spacecraft file
   m_file_search = multi_file_path+'/event_*wi0*'+event+'*.idl'
   m_file = file_search(m_file_search)
   
   restore, m_file
   new_Vm = create_struct('V_multi', mean(state.plane.V))
   new_Vm_std = create_struct('V_multi_std', stddev(state.plane.V))
   ;Get Nx, Ny, Nz
   new_Vm_NX = create_struct('V_multi_NX', mean(state.plane.N[*,0]))
   new_Vm_NY = create_struct('V_multi_NY', mean(state.plane.N[*,1]))
   new_Vm_NZ = create_struct('V_multi_NZ', mean(state.plane.N[*,2]))
   ; Standard deviation
   new_Vm_NX_std = create_struct('V_multi_NX_std', stddev(state.plane.N[*,0]))
   new_Vm_NY_std = create_struct('V_multi_NY_std', stddev(state.plane.N[*,1]))
   new_Vm_NZ_std = create_struct('V_multi_NZ_std', stddev(state.plane.N[*,2]))

   ;Phi and theta for multi-spacecraft
   new_Vm_phi = create_struct('V_multi_phi', mean(180 + atan(state.plane.n[*,1], state.plane.n[*,0])/!dtor))
   new_Vm_phi_std = create_struct('V_multi_phi_std', stddev(180 + atan(state.plane.n[*,1], state.plane.n[*,0])/!dtor))
   new_Vm_theta = create_struct('V_multi_theta', mean(180 + atan(state.plane.n[*,2], state.plane.n[*,0])/!dtor))
   new_Vm_theta_std = create_struct('V_multi_theta_std', stddev(180 + atan(state.plane.n[*,2], state.plane.n[*,0])/!dtor))

   ;Get WIND positioning data from multi-spacecraft file
   new_Wi_X = create_struct('Wi_X', median(state.data.wi.o.x))
   new_Wi_Y = create_struct('Wi_Y', median(state.data.wi.o.y))
   new_Wi_Z = create_struct('Wi_Z', median(state.data.wi.o.z))

   ;Check if there is STEREO A data present (events 871-878)
   spcrfts = tag_names(state.data)
   stereo_test = where(spcrfts eq 'ST')
   ;Assign 'Nan' if the data doesn't exist
   if stereo_test eq -1 then begin
      new_st_tshift = create_struct('St_tshift', 'NaN')
      new_St_X = create_struct('St_X', 'NaN')
      new_St_Y = create_struct('St_Y', 'NaN')
      new_St_Z = create_struct('St_Z', 'NaN')
   ;Assign the proper data if test is successfull  
   endif else begin
      new_st_tshift = create_struct('St_tshift', state.tshifts.st)
      new_St_X = create_struct('St_X', median(state.data.st.o.x))
      new_St_Y = create_struct('St_Y', median(state.data.st.o.y))
      new_St_Z = create_struct('St_Z', median(state.data.st.o.z))
   endelse   

   ;Add blank event note
   event_note = 'Event automatically added to database'
   new_event_note = create_struct('Notes', event_note)

   ;Create stucture containing all of the new event info
   new_event_data = create_struct(new_Date_JD, new_Date_YYYYMMDD, new_Time, new_type, new_Vs, new_Vs_std, new_Vs_error, new_Vm, new_Vm_std, new_Vm_NX, new_Vm_NX_std, new_Vm_NY, new_Vm_NY_std, new_Vm_Nz, new_Vm_NZ_std, new_Vm_phi, new_Vm_phi_std, new_Vm_theta, new_Vm_theta_std, new_compress, new_compress_error, new_theta_Bn, new_theta_Bn_error, new_normtheta, new_normtheta_error, new_normphi, new_normphi_error, new_Wi_X, new_Wi_Y, new_Wi_Z, new_St_tshift, new_St_X, new_St_Y, new_St_Z, new_event_note)

   ;add to current structure if it exists
   if  test_for_new_database eq 0 then begin
      shocks=create_struct(shocks, 'E'+string(event), new_event_data)
   ;Add to new structure if starting new
   endif else begin
      shocks=create_struct('E'+string(event), new_event_data)
      ;Switch to adding to the structure instead of starting over
      test_for_new_database = 0
   endelse
ENDFOREACH

print, 'Finished adding events. Saving file'
save, shocks, filename=database_filename

;Also write to CSV file
csv_filename = 'Single_and_Multi_SC_Shock_DB.csv'
;Convert to useable array structure first
shocking_array = shock_db_to_array()

;CSV headers
shocking_header = ['ID', 'JD', 'YYYYMMDD', 'Time','Shock_Type', 'V_Multi', 'V_Multi_STD', 'V_multi_Nx', 'V_multi_Nx_std', 'V_multi_NY', 'V_multi_NY_std',  'V_multi_NZ', 'V_multi_NZ_std',  'V_multi_phi',  'V_multi_phi_std', 'V_multi_theta', 'V_multi_theta_std', 'V_Single', 'V_Single_STDDEV', 'V_Single_Error', 'Compress', 'Compress_Error', 'Theta_BN', 'Theta_BN_Error', 'Norm_Theta', 'Norm_Theta_Error', 'Phi', 'Phi_Error', 'Wind_X', 'Wind_Y', 'Wind_Z', 'Stereo_Tshift', 'Stereo_X', 'Stereo_Y', 'Stereo_Z', 'Notes']

write_csv, csv_filename, shocking_array, header=shocking_header
print, 'Wrote CSV file to: '+csv_filename   


end
