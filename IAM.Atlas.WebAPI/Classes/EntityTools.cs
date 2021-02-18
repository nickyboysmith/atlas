using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace IAM.Atlas.WebAPI.Classes
{
    public class EntityTools
    {
        /// <summary>
        /// Points all ICollections<T> to null so it is easier to update in the DB, that is so we don't have to set the 
        /// entity state to modified for all the child entities.
        /// </summary>
        /// <param name="entity">The enitity object we want to strip the ICollections from. </param>
        /// <returns>The entity object with all the ICollections taken out.</returns>
        public static object NullifyICollections(object entity)
        {
            var nullifiedEntity = entity;   // make a copy of the entity to modify
            foreach(var property in nullifiedEntity.GetType().GetProperties())
            {
                if(property.PropertyType.FullName.StartsWith("System.Collections.Generic.ICollection"))
                {
                    property.SetValue(nullifiedEntity, null);
                }
            }
            return nullifiedEntity;
        }
    }
}
