PRO shock_db_manager

; Main structure is 'shocks'
;
; shocks.E### = event ID number
;
; shocks.###.Date_JD = JD datetime of the shock at Wind
; shocks.###.Date_YYYYMMDD = YYYYMMDD of the shock at Wind
; shocks.###.Time = time of arrival of the shock at Wind
; shocks.###.Shock_Type = type of shock event
; shocks.###.notes = Notes on the shock event (managed by this database)
; shocks.###.V_multi = mutliple spacecraft MEAN shock speed
; shocks.###.V_multi_std = multiple spacecraft standard deviation
; shocks.###.V_multi_NX = multiple spacecraft Nx
; shocks.###.V_multi_NX_std = multiple spacecraft Nx stddev
; shocks.###.V_multi_NY = multiple spacecraft NY
; shocks.###.V_multi_NY_std = multiple spacecraft NY stddev; 
; shocks.###.V_multi_NZ = multiple spacecraft NZ
; shocks.###.V_multi_NZ_std = multiple spacecraft NZ stddev; 
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

test1 = mean([1,2,3])
test2 = stddev([1,2,3])

;Single and multi=spacecraft file paths
s_file = '/crater/projects/shockdb/shocks/shockdb/shockdb_wi.idl'
multi_file_path = '/crater/projects/structures/l1_formations'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set the database structure name
database_filename = 'Single_and_Multi_SC_Shock_database.idl'

; Set action to blank string to start
action = ''

;If file exits, restore the data
if file_test(database_filename) eq 1 then begin
   test_for_new_database = 0
   ;restore the file
   restore, database_filename

   ;Print out the options to the user
   ;Jump back to options menu if there are errors
   OPTIONS_MENU: wait, 1
   print, ''
   print, '#########################################'
   print, 'Please select from the following options'
   print, '#########################################'
   wait, 0.5
   print, 'a --- (a)dd new entry'
   print, 'd --- (d)elete entry'
   print, 'i --- (i)nformation of entry'
   print, 's --- (s)earch for new entries'
   print, 'x --- e(x)it the program and SAVE'
   print, '#########################################'
   print, ''
   wait, 0.5
   read, action, PROMPT='Please select from the options above: '

;If file doesn't exist, create temporary structure to use
endif else begin
   test_for_new_database = 1
   print, 'No database found!'
   wait, 1
   print, 'Will create database from scratch'
  
   ;Print out reduced the options to the user
   REDUCED_MENU: wait, 1
   print, ''
   print, '#########################################'
   print, 'Please select from the following options'
   print, '#########################################'
   wait, 0.5
   print, 'a --- (a)dd new entry'
   print, 's --- (s)earch for new entries'
   print, 'x --- e(x)it the program and SAVE'
   print, '#########################################'
   print, ''
   wait, 0.5
   read, action, PROMPT='Please select from the options above: '
endelse

;Run while loop until users choses to exit
while action ne 'x' do begin

   ;Print out current events in the databse
   if test_for_new_database ne 1 then begin
      print, 'The following shocks are stored in this database'
      db_event_list = tag_names(shocks)
      print, '***************************************************'
      print, db_event_list
      print, '***************************************************'
      wait, 1
    endif
   
;;;;;;;;;;;;;;;;;; ACTION A ;;;;;;;;;;;;;;;;;;;;;;;;
   if action eq 'a' then begin
      
      ;get new ID to add to databse
      new_ID = ''
      read, new_ID, PROMPT='Enter new shock ID to add: '

      ;first check if file is already in databse (if database exists already)
      if test_for_new_database ne 1 then begin
         database_events = tag_names(shocks)
         ID_check = 'E'+new_ID
         ID_test = where(database_events eq ID_check)
         if ID_test ne -1 then begin
            print, 'ERROR: '+ID_check+' already exists in this database'
            wait, 0.5
            print, 'To modify or update selection, please (d)elete and re-add'
            wait, 1.0
            print, 'Returning to options menu'
            wait, 0.5
            GOTO, OPTIONS_MENU
          endif
      endif
      
      ;Search for the multi-spacecraft file
      m_file_search = multi_file_path+'/event_*wi0*'+new_ID+'*.idl'
      m_file = file_search(m_file_search)

      ;If file doesn't exist for the multi-spacecraft, break the loop
      if  (file_test(m_file) eq 0) then begin
         print,  'ERROR! Cannot locate multi spacecraft data at '+m_file_search
         wait, 0.5
         print, 'Returning to options menu'
         wait, 1
         GOTO, OPTIONS_MENU
      endif

      ;Restore single spacecraft file
      print, 'Restoring single-spacecraft file...'
      wait, 0.25
      restore, s_file
      ;Create holder list of all the catalog shocks
      event_list = shockdb.events

      ;Convert the event number to integer and get indexed array of correct data
      event_number = uint(New_ID)
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

      ;Renormalized uncertainty for single error
      basic_Vs_error = event_data.RH08.shock_speed.err
      chi_sq = event_data.RH08.CHISQMIN
      dof = event_data.RH08.DOF
      new_Vs_error = create_struct('V_single_error',(basic_Vs_error*dof)/(chi_sq))

      ;find the new multi-spacecraft data points
      print, 'Restoring multi-spacecraft file...'
      wait, 0.25
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
      new_Vm_theta = create_struct('V_multi_theta', mean(180 - atan(state.plane.n[*,2], state.plane.n[*,0])/!dtor))
      new_Vm_theta_std = create_struct('V_multi_theta_std', stddev(180 - atan(state.plane.n[*,2], state.plane.n[*,0])/!dtor))
     
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

      print, 'The following data will be added:'
      wait, 0.25
      print, 'Event number                        : '+string(new_ID)
      print, 'Arrival date at wind (YYYYMMDD)     : '+string(new_date_YYYYMMDD.date_YYYYMMDD)
      print, 'Arrival time at wind (UT)           : '+string(new_time.time)
      print, 'Shock type                          : '+string(new_type.Shock_type)
      print, 'Single Spacecraft average velocity  : '+string(new_Vs.V_single)
      print, 'Single Spacecraft velocity stddev   : '+string(new_Vs_std.V_single_std)
      print, 'Single Spacecraft renormalized error: '+string(new_Vs_error.V_single_error)
      print, 'Multi Spacecraft average velocity   : '+string(new_Vm.V_multi)
      print, 'Multi Spacecraft velocity stddev    : '+string(new_Vm_std.V_multi_std)
      print, 'Multi Spacecraft phi                : '+string(new_Vm_phi.V_multi_phi)
      print, 'Multi Spacecraft theta              : '+string(new_Vm_theta.V_multi_theta)
      print, 'Compression Ratio                   : '+string(new_compress.V_single_compress)
      print, 'Compression Ratio Error             : '+string(new_compress_error.V_single_compress_error)
      print, 'Theta Bn                            : '+string(new_theta_Bn.V_single_theta_bn)
      print, 'Theta Bn error                      : '+string(new_theta_Bn_error.V_single_theta_bn_error)
      print, 'Norm Theta                          : '+string(new_normtheta.V_single_normtheta)
      print, 'Norm Theta Error                    : '+string(new_normtheta_error.V_single_normtheta_error)
      print, 'Norm Phi                            : '+string(new_normphi.V_single_phi)
      print, 'Norm Phi Error                      : '+string(new_normphi_error.V_single_phi_error)
      print, ''
      wait,0.5
      
      ;Allow user to add note to the file
      print, 'Please add any notse to include for this event'
      wait, 0.5
      event_note = ''
      read, event_note, PROMPT='Add note for this event: '
      new_event_note = create_struct('Notes', event_note)
      
      ;Create stucture containing all of the new event info
      new_event_data = create_struct(new_Date_JD, new_Date_YYYYMMDD, new_Time, new_type, new_Vs, new_Vs_std, new_Vs_error, new_Vm, new_Vm_std, new_Vm_NX, new_Vm_NX_std, new_Vm_NY, new_Vm_NY_std, new_Vm_Nz, new_Vm_NZ_std, new_Vm_phi, new_Vm_phi_std, new_Vm_theta, new_Vm_theta_std, new_compress, new_compress_error, new_theta_Bn, new_theta_Bn_error, new_normtheta, new_normtheta_error, new_normphi, new_normphi_error, new_Wi_X, new_Wi_Y, new_Wi_Z, new_St_tshift, new_St_X, new_St_Y, new_St_Z, new_event_note)
      
      ;add new event to shocks structure depending on if starting new
      if  test_for_new_database eq 0 then begin
         shocks=create_struct(shocks, 'E'+string(new_ID), new_event_data)
      endif else begin
         shocks=create_struct('E'+string(new_ID), new_event_data)
         ;Switch to adding to the structure instead of starting over
          test_for_new_database = 0
      endelse

      print, 'Data successfully added!'
      wait, 0.5
      print, ''
      print, 'Saved new file to '+string(database_filename)
      save, shocks, filename=databae_filename 
      test_for_new_database = 0
   endif

  ;;;;;;;;;;;;;;;;;; ACTION D ;;;;;;;;;;;;;;;;;;;;;;;;
   if action eq 'd' then begin
      ;If databse not yet created, jump back to menu
      if test_for_new_database eq 1 then begin
         print, 'ERROR. No databse exits!'
         wait, 0.5
         print, 'Returning to options menu'
         wait, 1
         GOTO, REDUCED_MENU
      endif

      delete_ID = ''
      read, delete_ID, PROMPT='Enter shock ID (###) to remove: '
      print, 'Removing shock event number: '+string(delete_ID)
      delete_check = 'E'+delete_ID

      ;get list of all events
      database_events = tag_names(shocks)
      
      ;If only one event in database
      if n_elements(database_events) lt 2 then begin
         print, 'ERROR!!!!! CANNOT DELTE ONLY EVENT'
         print, 'Delete file manually and start over'
         print, 'Or add another event and THEN delete this one'
         wait, 2
         GOTO, OPTIONS_MENU
      endif

      ;Delete the one to be removed
      events_to_keep = database_events(where(database_events ne delete_check))
      if n_elements(events_to_keep) ne n_elements(database_events) then begin
          ;storage stucture
         temp_shocks = create_struct(events_to_keep[0], shocks.(0))
         ;Populate new structure
         for i=1,n_elements(events_to_keep)-1 do begin
            temp_shocks = create_struct(temp_shocks, events_to_keep[i], shocks.(i))
         endfor
         ;reassign structure name to new one with deleted entry
         shocks = temp_shocks
         ;Save new file after deleting
         wait, 0.25
         print, ''
         print, 'Removed entry and saved new file to '+string(database_filename)
         save, shocks, filename=database_filename
      endif else begin
         print, 'Shock number '+delete_check+' is not currently in the database'
         wait, 0.5
         print, 'Returning to options menu'
         wait, 0.5
      endelse
   endif

  ;;;;;;;;;;;;;;;;;; ACTION I ;;;;;;;;;;;;;;;;;;;;;;;;
   if action eq 'i' then begin
       ;If databse not yet created, jump back to menu
      if test_for_new_database eq 1 then begin
         print, 'ERROR. No databse exits!'
         wait, 0.5
         print, 'Returning to options menu'
         wait, 1
         GOTO, REDUCED_MENU
      endif

      info_ID = ''
      read, info_ID, PROMPT='Enter shock ID (###) for more info: '
      print, 'Info for event number: '+string(info_ID)
      info_check = 'E'+info_ID
      database_events = tag_names(shocks)
      event_index = where(database_events eq info_check)
      if event_index ne -1 then begin
               print, 'Event number                        : '+string(info_ID)
               print, 'Arrival date at wind (YYYYMMDD)     : '+string(shocks.(event_index).date_YYYYMMDD)
               print, 'Arrival time at wind (UT)           : '+string(shocks.(event_index).time)
               print, 'Shock Type                          : '+string(shocks.(event_index).Shock_Type)
               print, 'Single Spacecraft average velocity  : '+string(shocks.(event_index).V_single)
               print, 'Single Spacecraft velocity stddev   : '+string(shocks.(event_index).V_single_std)
               print, 'Single Spacecraft renormalized error: '+string(shocks.(event_index).V_single_error)
               print, 'Multi Spacecraft average velocity   : '+string(shocks.(event_index).V_multi)
               print, 'Multi Spacecraft velocity stddev    : '+string(shocks.(event_index).V_multi_std)
               print, 'Compression Ratio                   : '+string(shocks.(event_index).V_single_compress)
               print, 'Compression Ratio Error             : '+string(shocks.(event_index).V_single_compress_error)
               print, 'Theta Bn                            : '+string(shocks.(event_index).V_single_theta_bn)
               print, 'Theta Bn error                      : '+string(shocks.(event_index).V_single_theta_bn_error)
               print, 'Norm Theta                          : '+string(shocks.(event_index).V_single_normtheta)
               print, 'Norm Theta Error                    : '+string(shocks.(event_index).V_single_normtheta_error)
               print, 'Norm Phi                            : '+string(shocks.(event_index).V_single_phi)
               print, 'Norm Phi Error                      : '+string(shocks.(event_index).V_single_phi_error)
               print, 'Shock Notes                         : '+string(shocks.(event_index).Notes)
               print, ''
      endif else begin
         print, 'Shock number '+info_check+' is not currently in the database'
         wait, 0.5
         print, 'Returning to options menu'
         wait, 0.5
      endelse
   endif

  ;;;;;;;;;;;;;;;;;; ACTION S ;;;;;;;;;;;;;;;;;;;;;;;;
   if action eq 's' then begin
      print, 'Searching for events not yet in this database'
      ; Create storage to build the ID's to print
      IDs_to_test = []
      wait, 0.5

      ;search at the path location for all events (start with event_YYYYMMDD_00###.idl)
      m_file_search = multi_file_path+'/event_*_wi*.idl'
      m_files = file_search(m_file_search)
      foreach entry, m_files do begin
         ID_to_add = entry.split('wi')
         ID_to_add1 = ID_to_add[1]
         ID_to_add2 = ID_to_add1.split('.idl')
         ID_to_add3 = ID_to_add2[0]
         ID_to_add4 = ID_to_add3.replace('00','E')
         IDs_to_test = [IDs_to_test, ID_to_add4]
      endforeach
      
      ;If no database exists, print all available files
      if test_for_new_database eq 1 then print, IDs_to_test
      
      ;Only print out options not in database already if it exists
      if test_for_new_database eq 0 then begin
         IDs_to_print = []
         database_events = tag_names(shocks)
         foreach ID, IDs_to_test do begin
            ID_test = where(database_events eq ID)
            if ID_test eq -1 then IDs_to_print = [IDs_to_print, ID]
         endforeach
         ;Sort and print
         IDs_to_print = IDs_to_print[sort(IDs_to_print)]
         print, 'The following multi-spacecraft events exist but are not in the databse...'
         print, IDs_to_print
      endif
   endif
      
   ;Jump back to main menu or reduced menu
   if test_for_new_database eq 1 then GOTO, REDUCED_MENU
   if test_for_new_database eq 0 then GOTO, OPTIONS_MENU

endwhile

;Exit if no database was ever created
if test_for_new_database eq 1 then return

;Sort the file by event number
database_events = tag_names(shocks)

;Organize only if more than one entry
if n_elements(database_events) gt 1 then begin
   ;Sort the file by event number
   sort_index = sort(database_events)
   ;Use the first index to create temp structure
   temp_shocks = create_struct(database_events(sort_index[0]), shocks.(sort_index[0]))
   ;Chop off first index (added above) and then add the rest
   sort_index = sort_index(1:n_elements(sort_index)-1)
;Sort based on the sorted index and add to temp structure
   foreach n, sort_index do begin
      temp_shocks = create_struct(temp_shocks, database_events[n], shocks.(n))
   endforeach
;If only 1 entry 
endif else begin
   temp_shocks=shocks
endelse

;rename to shocks but ordered this time
shocks = temp_shocks
;save file
wait, 0.75
print, ''
print, 'Sorted and saved new file to '+string(database_filename)
save, shocks, filename=database_filename

;Also write to CSV file
csv_filename = 'Single_and_Multi_SC_Shock_DB.csv'
;Convert to useable array structure first, not sorted by events
shocking_array = shock_db_to_array()

;CSV headers
shocking_header = ['ID', 'JD', 'YYYYMMDD', 'Time','Shock_Type', 'V_Multi', 'V_Multi_STD', 'V_multi_Nx', 'V_multi_Nx_std', 'V_multi_NY', 'V_multi_NY_std',  'V_multi_NZ', 'V_multi_NZ_std',  'V_multi_phi',  'V_multi_phi_std', 'V_multi_theta', 'V_multi_theta_std', 'V_Single', 'V_Single_STDDEV', 'V_Single_Error', 'Compress', 'Compress_Error', 'Theta_BN', 'Theta_BN_Error', 'Norm_Theta', 'Norm_Theta_Error', 'Phi', 'Phi_Error', 'Wind_X', 'Wind_Y', 'Wind_Z', 'Stereo_Tshift', 'Stereo_X', 'Stereo_Y', 'Stereo_Z','Notes']

;Write to CSV
write_csv, csv_filename, shocking_array, header=shocking_header
print, 'Wrote CSV file to: '+csv_filename   
;

end
