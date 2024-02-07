#Making suer system has time to boot
get-service adws | fl 
timeout /t 60
start-service adws 
get-service adws | fl 
