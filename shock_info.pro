PRO shock_info

; print out shock info for a given event number
;
; Currently set up to only run on multi-spacecrafts that have been
;organized by Sophia in her home directory
;Would need better organization rules (or more robust file searching)
;to add more generic events
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Prompt the user for event ID number
event= ''
read, event, PROMPT= 'Enter Shock ID: '

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;single spacecraft
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;File path to single spacecraft database 
s_file = '/crater/projects/shockdb/shocks/shockdb/shockdb_wi.idl'
single_file_test = file_test(s_file)

;Quit program if single file doesn't exist
if (single_file_test eq 0) then begin
   print, 'ERROR! Cannot locate single spacecraft data at '+s_file
   return
endif

;Restore single spacecraft file
restore, s_file
;Create holder list of all the catalog shocks
event_list = shockdb.events
;Convert the event number to integer and get indexed array of correct data
event_number = uint(event)
event_data = event_list[event_number]

;Grab the correct single spacecraft data
Vs = event_data.RH08.shock_speed.avg
basic_Vs_error = event_data.RH08.shock_speed.err
dof = event_data.RH08.DOF
chi_sq = event_data.RH08.CHISQMIN
Vs_error = (basic_Vs_error*dof)/(chi_sq) ;renormalized uncertainty calc
compress = event_data.RH08.compression.avg
compress_error = event_data.RH08.compression.err
theta_Bn = event_data.RH08.theta_bn.avg
theta_Bn_error = event_data.RH08.theta_bn.err
normtheta = event_data.RH08.norm_theta.avg
normtheta_error = event_data.RH08.norm_theta.err
normphi = event_data.RH08.norm_phi.avg
normphi_error = event_data.RH08.norm_phi.err

;;;;;;;;;;;;;;;;;;;;;;;
;multi-spacecraft stuff
;;;;;;;;;;;;;;;;;;;;;;;

;Multispacecraft located at Sophia Davis directory with ####shock.idl format
multi_file_path = '/home.ufs/sdavis/phase3/'
multi_file_name = strcompress(event)+'shock.idl'
m_file = strcompress(multi_file_path)+strcompress(multi_file_name)

;serach for both multi-spacecraft file and quit if not there
multi_file_test = file_test(m_file)
if  (multi_file_test eq 0) then begin
   print, 'ERROR! Cannot locate multi spacecraft data at '+strcompress(m_file) 
   return
endif

;restore multi spacecraft data
restore, m_file
Vm = mean(state.plane.V)
Vm_std = stddev(state.plane.V)

;print out data summary
print, 'Event number: '+string(event)
print, 'Single Spacecraft average velocity (km/s)   : '+strcompress(Vs)
print, 'Single Spacecraft renormalized error (km/s) : '+strcompress(Vs_error)
print, 'Multi Spacecraft average velocity (km/s)    : '+strcompress(Vm)
print, 'Multi Spacecraft velocity stddev (km/s)     : '+strcompress(Vm_std)
print, 'Compression Ratio                           : '+strcompress(compress)
print, 'Compression Ratio Error                     : '+strcompress(compress_error)
print, 'Theta Bn (Degrees)                          : '+strcompress(theta_Bn)
print, 'Theta Bn error (Degrees)                    : '+strcompress(theta_Bn_error)
print, 'Norm Theta (Degrees)                        : '+strcompress(normtheta)
print, 'Norm Theta Error (Degrees)                  : '+strcompress(normtheta_error)
print, 'Norm Phi (Degrees)                          : '+strcompress(normphi)
print, 'Norm Phi Error (Degrees)                    : '+strcompress(normphi_error)
wait,0.5

end
