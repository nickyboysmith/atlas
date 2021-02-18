using IAM.Atlas.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Classes
{
    public class DORSTools
    {
        List<DORSAttendanceState> dorsAttendanceStates = null;
        public int GetDORSAttendanceStateId(int dorsAttendanceStateIdentifier, Atlas_DevEntities db)
        {
            var attendanceStateId = -1;
            if(dorsAttendanceStates == null)
            {
                dorsAttendanceStates = db.DORSAttendanceStates.ToList();
            }
            var attendanceState = dorsAttendanceStates.Where(das => das.DORSAttendanceStateIdentifier == dorsAttendanceStateIdentifier).FirstOrDefault();
            if(attendanceState != null)
            {
                attendanceStateId = attendanceState.Id;
            }
            return attendanceStateId;
        }
    }
}
