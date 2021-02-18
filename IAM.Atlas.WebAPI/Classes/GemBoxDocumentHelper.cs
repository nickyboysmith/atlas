using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using GemBox.Document;

namespace IAM.Atlas.WebAPI.Classes
{
    public static class GemBoxDocumentHelper
    {
        public static DocumentModel JoinWith(this DocumentModel destinationDocument, string filePath)
        {
            DocumentModel sourceDocument = DocumentModel.Load(filePath);
            foreach (Section sourceSection in sourceDocument.Sections)
            {
                Section destinationSection = destinationDocument.Import(sourceSection, true, false);
                destinationDocument.Sections.Add(destinationSection);
            }
            return destinationDocument;
        }
    }
}