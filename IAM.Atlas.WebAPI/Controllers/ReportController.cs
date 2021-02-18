using IAM.Atlas.Data;
using System;
using System.Drawing;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.ModelBinding;
using System.Net.Http.Formatting;
using System.Data.Entity;
using System.Data.Entity.Validation;
using IAM.Atlas.WebAPI.Models;
using IAM.Atlas.WebAPI.Classes;
using System.Web.Http.Controllers;

//using System;
//using System.Collections.Generic;
//using System.Linq;
using System.Text;
//using System.Data.Entity;
using System.Collections;
using System.Reflection.Emit;
using System.Reflection;

namespace IAM.Atlas.WebAPI.Controllers
{
    [AllowCrossDomainAccess]
    public class ReportController : AtlasBaseController
    {
        [AuthorizationRequired]
        [Route("api/report/{reportId}")]
        [HttpGet]
        public object Get(int reportId)
        {
            var report = atlasDB.Reports
                            .Include(r => r.ReportDataGrids)
                            .Include("ReportDataGrids.ReportDataGridColumns")
                            .Include(r => r.ReportCharts)
                            .Include("ReportCharts.ReportChartColumns")
                            .Include(r => r.ReportsReportCategories)
                            .Include(r => r.OrganisationReports)
                            .Include(r => r.ReportOwners)
                            .Include("ReportOwners.User")
                            .Where(r => r.Id == reportId).FirstOrDefault();
            return report;
        }

        [AuthorizationRequired]
        [Route("api/report/search/getreportsbyorganisation/{OrganisationId}")]
        [HttpGet]
        public object GetReportsByOrganisation(int OrganisationId)
        {
            var returnObject = atlasDB.OrganisationReports
                .Include("Report")
                .Where(or => or.OrganisationId == OrganisationId)
                .ToList()
                .Select(
                newReport => new
                {
                    Id = newReport.Report.Id,
                    DisplayName = newReport.Report.Title
                })
                .OrderBy(n => n.DisplayName);

            return returnObject;
        }
        [AuthorizationRequired]
        [Route("api/report/search/getreportsbycategory/{CategoryId}")]
        [HttpGet]
        public object GetReportsByCategory(int CategoryId)
        {
            var returnObject = atlasDB.ReportsReportCategories
                 .Include("Report")
                 .Where(rrc => rrc.ReportCategoryId == CategoryId)
                 .ToList()
                 .Select(
                 newReport => new
                 {
                     Id = newReport.Report.Id,
                     DisplayName = newReport.Report.Title
                 })
                 .OrderBy(n => n.DisplayName);

            return returnObject;
        }
        [AuthorizationRequired]
        [Route("api/report/search/getreportsbyuser/{UserId}")]
        [HttpGet]
        public object GetReportsByUser(int UserId)
        {
            var returnObject = atlasDB.ReportOwners
                .Include("Report")
                .Where(ro => ro.UserId == UserId)
                .ToList()
                .Select(
                newReport => new
                {
                    Id = newReport.Report.Id,
                    DisplayName = newReport.Report.Title
                })
                 .OrderBy(n => n.DisplayName);

            return returnObject;
        }

        /// <summary>
        /// Get data view columns
        /// </summary>
        /// <param name="dataViewId"></param>
        /// <returns></returns>
        [AuthorizationRequired]
        [Route("api/report/getdatacolumns/{dataViewId}")]
        [HttpGet]
        public object GetDataColumns(int dataViewId)
        {
            return atlasDB.DataViewColumns
                    .Where(dv => dv.DataViewId == dataViewId)
                    .ToList()
                    .Select(d => new
                    {
                        Id = d.Id,
                        Name = d.Name,
                        Title = d.Title
                    });
        }

        /// <summary>
        /// Get data view columns, left joined with sort information
        /// </summary>
        /// <param name="reportId"></param>
        /// <returns></returns>
        [AuthorizationRequired]
        [Route("api/report/GetDataColumnsWithSortOrder/{reportId}")]
        [HttpGet]
        public object GetDataColumnsWithSortOrder(int reportId)
        {
            return atlasDB.ReportDataGridColumns
                            .Include(d => d.ReportDataGrid)
                            .Include(d => d.DataViewColumn)
                            .Where(d => d.ReportDataGrid.ReportId == reportId)
                            .ToList()
                            .Select(d => new
                            {
                                Id = d.DataViewColumnId,
                                Name = d.DataViewColumn.Name,
                                Title = d.DataViewColumn.Title,
                                SortOrder = d.SortOrder,
                                DisplayOrder = d.DisplayOrder
                            });

            //var dataColumnsWithSortOrder = from dataViewColumn in atlasDB.DataViewColumns
            //                               join reportDataGridColumn in atlasDB.ReportDataGridColumns 
            //                                    on dataViewColumn.Id equals reportDataGridColumn.DataViewColumnId into reportDataGridColumns
            //                               from reportDataGridColumn in reportDataGridColumns.DefaultIfEmpty()
            //                               select new
            //                               {
            //                                   Id = dataViewColumn.Id,
            //                                   Name = dataViewColumn.Name,
            //                                   SortOrder = reportDataGridColumn == null ? -1 : reportDataGridColumn.SortOrder,
            //                                   DisplayOrder = reportDataGridColumn == null ? -1 : reportDataGridColumn.DisplayOrder
            //                               };

            //return dataColumnsWithSortOrder;

            //return atlasDB.DataViewColumns
            //                .Include(d => d.ReportDataGridColumns)
            //                .Include("ReportDataGridColumns.ReportDataGrid")
            //                .Where(d => d.ReportDataGridColumns.Any(r => r.ReportDataGrid.ReportId == reportId))

        }

        /// <summary>
        /// Get data sources
        /// </summary>
        /// <param name="dataViewId"></param>
        /// <returns></returns>
        [AuthorizationRequired]
        [Route("api/report/getdatasources")]
        [HttpGet]
        public object GetDataSources()
        {
            var returnData = atlasDB.DataViews
                       .ToList()
                       .Select(d => new
                       {
                           Id = d.Id,
                           Name = d.Name,
                           Title = d.Title
                       });

            return returnData;
        }

        // POST api/<controller>  
        [AuthorizationRequired]
        [Route("api/report/add")]

        public int Post([FromBody] FormDataCollection formBody)
        {

            FormDataCollection formData = formBody;

            var reportColumns = StringTools.GetIntArray("reportColumns", ',', ref formData);
            var chartColumns = StringTools.GetIntArray("chartColumns", ',', ref formData);
            var title = StringTools.GetString("Title", ref formData);
            var description = StringTools.GetString("Description", ref formData);
            var createdByUserId = StringTools.GetInt("userId", ref formData);
            var dateCreated = DateTime.Now;
            var reportCategoryId = StringTools.GetInt("selectedReportCategory", ref formData);
            var chartType = StringTools.GetString("selectedChartType", ref formData);
            var dataViewId = StringTools.GetInt("selectedDataSource", ref formData);
            var userId = StringTools.GetInt("userId", ref formData);
            var organisationId = StringTools.GetInt("selectedOrganisation", ref formData);
            var reportId = StringTools.GetInt("Id", ref formData);

            var columnOrderAndSortByOrderLists = formData.ReadAs<ColumnOrderAndSortByOrderLists>();

            //Error checking
            // check the title isnt empty
            if (String.IsNullOrEmpty(title))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("The title is empty."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            // check the description isnt empty
            if (String.IsNullOrEmpty(description))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("The description is empty."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            // check the organisation is valid
            if (!(organisationId > 0 || organisationId == -1))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("The organisation is not valid."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            // check the data source is valid
            if (!(dataViewId > 0))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("The data source is not valid."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            // check the report columns have been selected
            if (!(reportColumns.Count() > 0))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("The report columns are not valid."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            //Create the report
            Report report;

            if (reportId > 0)
            {
                report = (Report)Get(reportId);
                report.Title = title;
                report.Description = description;
            }
            else
            {
                report = new Report
                {
                    Title = title,
                    Description = description,
                    CreatedByUserId = createdByUserId,
                    DateCreated = dateCreated
                };

                // add the Creating User as the Report Owner
                var reportOwner = new ReportOwner();
                reportOwner.UserId = (int)report.CreatedByUserId;
                report.ReportOwners.Add(reportOwner);
            }

            #region Chart and chart column editing and adding
            /*
                Build Chart Data
            */
            //Create the report chart
            ReportChart tempReportChart = new ReportChart
            {
                ChartType = chartType,
                DataViewId = dataViewId
            };

            //Retrieve and add the report chart columns
            foreach (var dataViewColumnId in chartColumns)
            {
                ReportChartColumn tempReportChartColumn = new ReportChartColumn
                {
                    DataViewColumnId = dataViewColumnId
                };
                tempReportChart.ReportChartColumns.Add(tempReportChartColumn);
            }
            // does this report data source already exist in the report?
            var chartExists = false;
            foreach (var reportChart in report.ReportCharts)
            {
                if (reportChart.ChartType == tempReportChart.ChartType &&
                    reportChart.DataViewId == tempReportChart.DataViewId)
                {
                    chartExists = true;
                }
                else
                {
                    chartExists = false;
                    break;
                }
            }
            if (!chartExists)
            {
                if (report.ReportCharts.Count > 0) // currently only one report per chart, but this will change in the future
                {
                    List<ReportChart> chartsToDelete = report.ReportCharts.ToList();
                    for (int i = 0; i < report.ReportCharts.Count; i++)      // traverse all the charts and delete from DB
                    {
                        if (chartsToDelete[i].ReportChartColumns.Count > 0)     // delete this chart's chart columns from DB
                        {
                            var chartColumnsToDelete = chartsToDelete[i].ReportChartColumns.ToList();
                            for (int j = 0; j < chartsToDelete[i].ReportChartColumns.Count; j++)
                            {
                                var chartColumnEntry = atlasDB.Entry(chartColumnsToDelete[j]);
                                chartColumnEntry.State = EntityState.Deleted;
                            }
                        }
                        var chartEntry = atlasDB.Entry(chartsToDelete[i]);
                        chartEntry.State = EntityState.Deleted;
                    }
                }
                report.ReportCharts.Add(tempReportChart);
            }
            else // delete the chart columns that aren't in the form, add the new ones
            {
                var chartColumnsToDelete = new List<ReportChartColumn>();
                foreach (var reportChartColumn in report.ReportCharts.First().ReportChartColumns)
                {
                    if (!tempReportChart.ReportChartColumns.Any(trcc => trcc.DataViewColumnId == reportChartColumn.DataViewColumnId))
                    {
                        chartColumnsToDelete.Add(reportChartColumn);
                    }
                }
                // can't delete from source we are iterating from so...
                for (int i = 0; i < chartColumnsToDelete.Count; i++)
                {
                    var chartColumnToDeleteEntry = atlasDB.Entry(chartColumnsToDelete[i]);
                    chartColumnToDeleteEntry.State = EntityState.Deleted;
                }
                foreach (var tempReportChartColumn in tempReportChart.ReportChartColumns)
                {
                    // currently only allowed one chart per report (this will change!)
                    if (!report.ReportCharts.First().ReportChartColumns.Any(rcc => rcc.DataViewColumnId == tempReportChartColumn.DataViewColumnId))
                    {
                        // column does not exist, add it
                        report.ReportCharts.First().ReportChartColumns.Add(tempReportChartColumn);
                    }
                }
            }
            #endregion

            #region Report Data Grid and Data Column editing and adding
            /*
                Build the Report Data
            */
            //Create the Report Data Grid
            ReportDataGrid tempReportDataGrid = new ReportDataGrid
            {
                DataViewId = dataViewId
            };

            //Retrieve and add the report data grid columns
            foreach (var dataViewColumnId in reportColumns)
            {
                ReportDataGridColumn tempReportDataGridColumn = new ReportDataGridColumn
                {
                    DataViewColumnId = dataViewColumnId
                };
                tempReportDataGrid.ReportDataGridColumns.Add(tempReportDataGridColumn);
            }

            // does this data grid already exist in the report?
            var gridExists = false;
            foreach (var dataGrid in report.ReportDataGrids)
            {
                if (dataGrid.DataViewId == tempReportDataGrid.DataViewId)
                {
                    gridExists = true;
                }
                else {
                    gridExists = false;
                    break;
                }
            }
            if (!gridExists)
            {
                if (report.ReportDataGrids.Count > 0) // only one data grid per chart
                {
                    List<ReportDataGrid> dataGridsToDelete = report.ReportDataGrids.ToList();
                    for (int i = 0; i < report.ReportDataGrids.Count; i++)   // traverse all the data grids and delete from DB
                    {
                        if (dataGridsToDelete[i].ReportDataGridColumns.Count > 0)    // delete this data grid's chart columns from DB
                        {
                            var dataGridColumnsToDelete = dataGridsToDelete[i].ReportDataGridColumns.ToList();
                            for (int j = 0; j < dataGridsToDelete[i].ReportDataGridColumns.Count; j++)
                            {
                                var dataGridColumnEntry = atlasDB.Entry(dataGridColumnsToDelete[j]);
                                dataGridColumnEntry.State = EntityState.Deleted;
                            }
                        }
                        var dataGridEntry = atlasDB.Entry(dataGridsToDelete[i]);
                        dataGridEntry.State = EntityState.Deleted;
                    }
                }
                report.ReportDataGrids.Add(tempReportDataGrid);
            }
            else // delete the report's data grid columns that aren't in the form, add the new ones
            {
                var dataGridColumnsToDelete = new List<ReportDataGridColumn>();
                foreach (var reportDataGridColumn in report.ReportDataGrids.First().ReportDataGridColumns)
                {
                    if (!tempReportDataGrid.ReportDataGridColumns.Any(trdgc => trdgc.DataViewColumnId == reportDataGridColumn.DataViewColumnId))
                    {
                        dataGridColumnsToDelete.Add(reportDataGridColumn);
                    }
                }
                // can't delete from source we are iterating from so...
                for (int i = 0; i < dataGridColumnsToDelete.Count; i++)
                {
                    var dataGridColumnToDeleteEntry = atlasDB.Entry(dataGridColumnsToDelete[i]);
                    dataGridColumnToDeleteEntry.State = EntityState.Deleted;
                }
                foreach (var tempReportDataGridColumn in tempReportDataGrid.ReportDataGridColumns)
                {
                    // only one data grid per report
                    if (!report.ReportDataGrids.First().ReportDataGridColumns.Any(rdgc => rdgc.DataViewColumnId == tempReportDataGridColumn.DataViewColumnId))
                    {
                        // column does not exist, add it
                        report.ReportDataGrids.First().ReportDataGridColumns.Add(tempReportDataGridColumn);
                    }
                }
            }
            #endregion

            #region Save the report column order and sort row by column order

            // reset the sort and display order values to -1
            if (report.ReportDataGrids.Count > 0)
            {
                foreach (var reportDataGridColumn in report.ReportDataGrids.First().ReportDataGridColumns)
                {
                    reportDataGridColumn.DisplayOrder = -1;
                    reportDataGridColumn.SortOrder = -1;
                }
            }

            if (columnOrderAndSortByOrderLists.columnOrder != null)
            {
                var currentOrderPostition = 1;
                foreach (var columnOrderEntry in columnOrderAndSortByOrderLists.columnOrder)
                {
                    if (report.ReportDataGrids.Count > 0)
                    {
                        foreach (var reportDataGridColumn in report.ReportDataGrids.First().ReportDataGridColumns)
                        {
                            if (reportDataGridColumn.DataViewColumnId == columnOrderEntry.Id)
                            {
                                reportDataGridColumn.DisplayOrder = currentOrderPostition;
                                currentOrderPostition++;
                                break;
                            }
                        }
                    }
                }
            }
            if (columnOrderAndSortByOrderLists.columnSortByOrder != null)
            {
                var currentSortByColumnPosition = 1;
                foreach (var columnSortByOrderEntry in columnOrderAndSortByOrderLists.columnSortByOrder)
                {
                    if (report.ReportDataGrids.Count > 0)
                    {
                        foreach (var reportDataGridColumn in report.ReportDataGrids.First().ReportDataGridColumns)
                        {
                            if (reportDataGridColumn.DataViewColumnId == columnSortByOrderEntry.Id)
                            {
                                reportDataGridColumn.SortOrder = currentSortByColumnPosition;
                                currentSortByColumnPosition++;
                                break;
                            }
                        }
                    }
                }
            }

            #endregion

            // Create the report category if an organisation specific category has been selected
            if (reportCategoryId > 0)
            {
                if (report.ReportsReportCategories.Count > 0)
                {
                    // already an entry
                    if (report.ReportsReportCategories.First().ReportCategoryId != reportCategoryId)
                    {
                        report.ReportsReportCategories.First().ReportCategoryId = reportCategoryId;
                    }
                }
                else
                {
                    ReportsReportCategory tempReportCategory = new ReportsReportCategory
                    {
                        ReportCategoryId = reportCategoryId
                    };
                    report.ReportsReportCategories.Add(tempReportCategory);
                }
            }

            //If Own Reports Only has been selected, don't add a ReportsReportCategories entry, instead add a UserReport entry
            if (reportCategoryId == -1)
            {
                // delete all existing ReportsReportCategories
                if (report.ReportsReportCategories.Count > 0)
                {
                    var reportsReportCategoriesToDelete = report.ReportsReportCategories.ToList();
                    for (int i = 0; i < report.ReportsReportCategories.Count; i++)
                    {
                        var reportsReportCategoriesToDeleteEntry = atlasDB.Entry(reportsReportCategoriesToDelete[i]);
                        reportsReportCategoriesToDeleteEntry.State = EntityState.Deleted;
                    }
                }

                // is there already a user report?
                if (report.UserReports.Count == 0)
                {
                    // no? then add one.
                    UserReport tempUserReport = new UserReport
                    {
                        UserId = userId
                    };
                    report.UserReports.Add(tempUserReport);
                }
            }

            //Handle for organisation access
            if (organisationId > 0)
            {
                if (!report.OrganisationReports.Any(o => o.OrganisationId == organisationId))
                {
                    var organisationReportsToDelete = report.OrganisationReports.ToList();
                    for (int i = 0; i < report.OrganisationReports.Count; i++)
                    {
                        var organisationReportToDeleteEntry = atlasDB.Entry(organisationReportsToDelete[i]);
                        organisationReportToDeleteEntry.State = EntityState.Deleted;
                    }
                    OrganisationReport tempOrganisationReport = new OrganisationReport
                    {
                        OrganisationId = organisationId
                    };
                    report.OrganisationReports.Add(tempOrganisationReport);
                }
            }

            if (organisationId == -1)
            {
                //Get all organisations

                var allOrganisations = atlasDB.Organisations.ToList();

                foreach (var org in allOrganisations)
                {
                    if (!report.OrganisationReports.Any(o => o.OrganisationId == org.Id))
                    {
                        OrganisationReport tempOrganisationReport = new OrganisationReport
                        {
                            OrganisationId = organisationId
                        };
                        report.OrganisationReports.Add(tempOrganisationReport);
                    }
                }
            }
            try
            {
                if (report.Id > 0)   // do a database update
                {
                    atlasDB.Reports.Attach(report);
                    var entry = atlasDB.Entry(report);
                    entry.State = System.Data.Entity.EntityState.Modified;
                }
                else    // add to the database
                {
                    atlasDB.Reports.Add(report);
                }
                atlasDB.SaveChanges();
            }
            catch (Exception ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Saving Failed."),
                        ReasonPhrase = "An Error occurred."
                    }
                );
            }
            return report.Id;
        }

        /// <summary>
        /// Clone an existing report  sourceReportID, cloneReportTitle, cloneReportDescription
        /// </summary>
        /// <param name="sourceReportID"></param>
        /// <param name="cloneReportTitle"></param>
        /// <param name="cloneReportDescription"></param>
        /// <returns>Id of newly cloned report</returns>
        [AuthorizationRequired]
        [HttpPost]
        [Route("api/report/clonereport")]
        public object CloneReport([FromBody] FormDataCollection formBody)
        {
            var cloneData = formBody.ReadAs<CloneData>();

            //Retrieve the source report that is to be cloned
            var sourceReport = atlasDB.Reports
                                .Include(i => i.OrganisationReports)
                                .Include(i => i.ReportCharts)
                                .Include(i => i.ReportCharts.Select(x => x.ReportChartColumns))
                                .Include(i => i.ReportDataGrids)
                                .Include(i => i.ReportDataGrids.Select(x => x.ReportDataGridColumns))
                                .Include(i => i.ReportsReportCategories)
                                .Include(i => i.UserReports)
                                .Include(i => i.OrganisationReports)
                                .Where(x => x.Id == cloneData.sourceReportID)
                                .First();
            //Error checking
            // check the title isnt empty
            if (String.IsNullOrEmpty(sourceReport.Title))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("The title is empty."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            // check the description isnt empty
            if (String.IsNullOrEmpty(sourceReport.Description))
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("The description is empty."),
                        ReasonPhrase = "We can't process your request."
                    }
                );
            }

            //Create the report
            Report tempReport = new Report
            {
                Title = cloneData.cloneReportTitle,
                Description = cloneData.cloneReportDescription,
                CreatedByUserId = cloneData.userID,
                DateCreated = DateTime.Now
            };

            /*
                Build Chart Data
            */
            //Create the report chart
            if (sourceReport.ReportCharts.Count() > 0)
            {
                ReportChart tempReportChart = new ReportChart
                {
                    ChartType = sourceReport.ReportCharts.First().ChartType,
                    DataViewId = sourceReport.ReportCharts.First().DataViewId
                };


                //Retrieve and add the report chart columns
                foreach (var reportChartColumn in sourceReport.ReportCharts.First().ReportChartColumns)
                {
                    ReportChartColumn tempReportChartColumn = new ReportChartColumn
                    {
                        DataViewColumnId = reportChartColumn.DataViewColumnId
                    };
                    tempReportChart.ReportChartColumns.Add(tempReportChartColumn);
                }

                tempReport.ReportCharts.Add(tempReportChart);
            }
            /*
                Build the Report Data
            */
            //Create the Report Data Grid

            if (sourceReport.ReportDataGrids.Count() > 0)
            {
                ReportDataGrid tempDataGrid = new ReportDataGrid
                {
                    DataViewId = sourceReport.ReportDataGrids.First().DataViewId
                };

                //Retrieve and add the report data grid columns
                foreach (var reportDataGridColumn in sourceReport.ReportDataGrids.First().ReportDataGridColumns)
                {
                    ReportDataGridColumn tempReportDataGridColumn = new ReportDataGridColumn
                    {
                        DataViewColumnId = reportDataGridColumn.DataViewColumnId
                    };
                    tempDataGrid.ReportDataGridColumns.Add(tempReportDataGridColumn);
                }

                tempReport.ReportDataGrids.Add(tempDataGrid);
            }

            //Duplicate either report category or user report relationship
            if (sourceReport.ReportsReportCategories.Count() > 0)
            {
                ReportsReportCategory tempReportCategory = new ReportsReportCategory
                {
                    ReportCategoryId = sourceReport.ReportsReportCategories.First().ReportCategoryId
                };
                tempReport.ReportsReportCategories.Add(tempReportCategory);
            }
            else
            {
                UserReport tempUserReport = new UserReport
                {
                    UserId = cloneData.userID
                };
                tempReport.UserReports.Add(tempUserReport);
            }

            //Duplicate organisation access
            foreach (var org in sourceReport.OrganisationReports)
            {
                OrganisationReport tempOrganisationReport = new OrganisationReport
                {
                    OrganisationId = org.OrganisationId
                };
                tempReport.OrganisationReports.Add(tempOrganisationReport);
            }

            try
            {
                atlasDB.Reports.Add(tempReport);
                atlasDB.SaveChanges();
            }
            catch (Exception ex)
            {
                throw new HttpResponseException(
                    new HttpResponseMessage(HttpStatusCode.Forbidden)
                    {
                        Content = new StringContent("Saving Failed."),
                        ReasonPhrase = "An Error occurred."
                    }
                );
            }
            return tempReport.Id;
        }

        // PUT api/<controller>/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/<controller>/5
        public void Delete(int id)
        {

        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/report/getAvailableUsers/{reportID}/{organisationId}")]
        public object getAvailableUsers(int reportId, int organisationId)
        {
            return atlasDB.Users
                            .Include(u => u.OrganisationUsers)
                            .Include(u => u.ReportOwners)
                            .Where(u => u.OrganisationUsers.Any(ou => ou.OrganisationId == organisationId) &&
                                   !u.ReportOwners.Any(ro => ro.ReportId == reportId)).ToList();
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/report/removeReportOwner/{reportID}/{userId}")]
        public object removeReportOwner(int reportId, int userId)
        {
            var removed = false;
            var reportOwner = atlasDB.ReportOwners.Where(ro => ro.ReportId == reportId && ro.UserId == userId).FirstOrDefault();
            if (reportOwner != null)
            {
                var entry = atlasDB.Entry(reportOwner);
                entry.State = EntityState.Deleted;
                atlasDB.SaveChanges();
                removed = true;
            }
            return removed;
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/report/addReportOwner/{reportID}/{userId}")]
        public object addReportOwner(int reportId, int userId)
        {
            var added = -1;
            var report = (Report)Get(reportId);
            if (report != null)
            {
                var reportOwner = new ReportOwner();
                reportOwner.UserId = userId;
                reportOwner.ReportId = reportId;

                atlasDB.ReportOwners.Add(reportOwner);
                atlasDB.SaveChanges();

                added = reportOwner.Id;
            }
            return added;
        }

        /// <summary>
        /// Returns details of the parameters required to run a report
        /// </summary>
        /// <param name="reportId"></param>
        /// <returns></returns>
        [AuthorizationRequired]
        [HttpGet]
        [Route("api/report/getreportinputparameters/{reportId}/{organisationId}")]
        public object getreportinputparameters(int reportId, int organisationId)
        {
            //Create the object to be returned
            ReportAttributes reportAttributes = new ReportAttributes();
            reportAttributes.inputParameters = new List<singleParameter>();

            //Obtain each of the parameters of the report
            var reportParameters =

                from r in atlasDB.Reports
                    //Left Join Report onto ReportDataGrid
                join rdg in atlasDB.ReportDataGrids on r.Id equals rdg.ReportId into rrdg
                from x in rrdg.DefaultIfEmpty()

                    //Left Join ReportDataGrid onto ReportParameter
                join rp in atlasDB.ReportParameters on x.Id equals rp.ReportDataGridId into xrp
                from y in xrp.DefaultIfEmpty()

                    //Left Join ReportParameter onto ReportDataType
                join rdt in atlasDB.ReportDataTypes on y.ReportDataTypeId equals rdt.Id into yrdt
                from z in yrdt.DefaultIfEmpty()

                where r.Id == reportId

                select new
                {
                    Id = r.Id
                    , ReportTitle = r.Title
                    , ReportDescription = r.Description
                    , ParameterId = y.Id
                    , ParameterName = y.Title
                    , ParameterType = z.DataTypeName
                };

            //Assign the basic report attributes

            reportAttributes.reportId = reportId;
            reportAttributes.reportTitle = reportParameters.FirstOrDefault().ReportTitle;
            reportAttributes.reportDescription = reportParameters.FirstOrDefault().ReportDescription;

            /*
            Some parameters will have specific options only (for instance a report may allow/require a user to input a particular payment method 
            or course type) so these (typically organisation specific) options must be passed back to enable correct building of the parameters input form. 
            Iterate through the parameters and build the report attributes object, with restricted options as required
            */
            foreach (var parameter in reportParameters)
            {
                if (parameter.ParameterName != null)
                {
                    List<parameterOption> newParameterOptions = new List<parameterOption>();

                    newParameterOptions = this.GetOrganisationParameterOptions(parameter.ParameterType, organisationId);

                    singleParameter singleParam = new singleParameter();
                    singleParam.parameterId = parameter.ParameterId;
                    singleParam.parameterTitle = parameter.ParameterName;
                    singleParam.parameterType = parameter.ParameterType;
                    singleParam.parameterOptions = newParameterOptions != null ? newParameterOptions : new List<parameterOption>();

                    reportAttributes.inputParameters.Add(singleParam);
                }
            }
            return reportAttributes;
        }

        [AuthorizationRequired]
        [HttpPost]
        [Route("api/report/runReportParameters")]
        public object runReportParameters([FromBody] FormDataCollection formBody)
        {
            FormDataCollection formData = formBody;

            var reportId = StringTools.GetInt("ReportId", ref formData);
            var orgId = StringTools.GetInt("OrganisationId", ref formData);
            var userId = StringTools.GetInt("UserId", ref formData);
            ReportRequest reportRequest = new ReportRequest();
            reportRequest.OrganisationId = orgId;
            reportRequest.ReportId = reportId;
            reportRequest.CreatedByUserId = userId;
            reportRequest.DateCreated = DateTime.Now;

            atlasDB.ReportRequests.Add(reportRequest);
            atlasDB.SaveChanges();

            var reportRequestId = reportRequest.Id;

            //Call SP
            //var reportData = atlasDB.uspGetReportData(reportRequestId);
            var reportData = atlasDB.Database.SqlQuery<object>("uspGetReportData @p0", reportRequestId);


            return reportData;
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/report/getReportRequest/{reportId}/{organisationId}/{userId}")]
        public int getReportRequest(int reportId, int organisationId, int userId)
        {
            ReportRequest reportRequest = new ReportRequest();
            reportRequest.OrganisationId = organisationId;
            reportRequest.ReportId = reportId;
            reportRequest.CreatedByUserId = userId;
            reportRequest.DateCreated = DateTime.Now;

            atlasDB.ReportRequests.Add(reportRequest);
            atlasDB.SaveChanges();

            var reportRequestId = reportRequest.Id;
            
            return reportRequestId;
        }

        [AuthorizationRequired]
        [HttpPost]
        [Route("api/report/postReportRequestParameterValue/{reportRequestId}/{parameterId}/{parameterValue}/{parameterValueText}")]
        public int saveReportRequestParameterValue(int reportRequestId, int parameterId, string parameterValue, string parameterValueText)
        {
            ReportRequestParameter reportRequestParameter = new ReportRequestParameter();
            reportRequestParameter.ReportRequestId = reportRequestId;
            reportRequestParameter.ReportParameterId = parameterId;
            reportRequestParameter.ParameterValue = parameterValue;
            reportRequestParameter.ParameterValueText = parameterValueText;

            atlasDB.ReportRequestParameters.Add(reportRequestParameter);
            atlasDB.SaveChanges();

            var reportRequestParameterId = reportRequestParameter.Id;

            return reportRequestParameterId;
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/report/getReportData/{reportRequestId}")]
        public object getReportData(int reportRequestId)
        {
            //Call SP
            var reportData = atlasDB
                                .Database
                                .SqlQuery<ReportData>("uspGetReportData @p0", reportRequestId);


            var reportRequest = atlasDB
                                    .ReportRequests
                                    .Where(x => x.Id == reportRequestId)
                                    .FirstOrDefault();


            reportRequest.NumberOfDataRows = reportData.Count();
            atlasDB.SaveChanges();

            return reportData;
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/report/getReportRequestData/{reportRequestId}")]
        public object getReportRequestData(int reportRequestId)
        {
            //var reportRequest = atlasDB
            //                        .ReportRequests
            //                        .Where(x => x.Id == reportRequestId)
            //                        .FirstOrDefault();
            var reportRequest = atlasDBViews
                                    .vwReportRequests
                                    .Where(x => x.ReportRequestId == reportRequestId)
                                    .FirstOrDefault();

            return reportRequest;
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/report/getReportColumns/{reportId}")]
        public object getReportColumns(int reportId)
        {
            var reportColumns = atlasDBViews
                                    .vwReportColumns
                                    .Where(x => x.ReportId == reportId)
                                    .DefaultIfEmpty()
                                    .ToList()
                                    .OrderBy(w => w.ColumnDisplayOrder);

            return reportColumns;
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/report/getReportReferenceData/{dataTypeName}/{organisationId}")]
        public object getReportReferenceData(string dataTypeName, int organisationId)
        {
            //NB. Below Returns Null As Errors when Nothing Returned
            switch (dataTypeName)
            {
                case "Venue":
                    try
                    { 
                        var venueList = atlasDBViews.vwReportsVenueDetails
                                        .Where(x => x.OrganisationId == organisationId)
                                        .DefaultIfEmpty()
                                        .Select(v => new
                                        {
                                            v.Id
                                            , v.Title
                                            , v.Enabled
                                            , v.AdditionalInformation
                                            , v.DORSVenue
                                            , Visible = true
                                        })
                                        .ToList()
                                        .OrderBy(w => w.Title);
                        return venueList;
                    }
                    catch (Exception ex)
                    {
                        return null;
                    }
                    break;
                case "Trainer":
                    try
                    {
                        var trainerList = atlasDBViews.vwReportsTrainerDetails
                                    .Where(x => x.OrganisationId == organisationId)
                                    .DefaultIfEmpty()
                                    .Select(v => new
                                    {
                                        v.TrainerId
                                        , TrainerName = v.TrainerName + " (Id: " + v.TrainerId + ")"
                                        , v.TrainerLicenceNumber
                                        , v.TrainerMainPhoneNumber
                                        , v.TrainerPostCode
                                        , Visible = true
                                    })
                                    .ToList()
                                    .OrderBy(w => w.TrainerName);
                        return trainerList;
                    }
                            catch (Exception ex)
                    {
                        return null;
                    }
                    break;
                case "ReferringAuthority":
                    try
                    {
                        var referringAuthorityList = atlasDBViews.vwReferringAuthorityDetails
                                    .DefaultIfEmpty()
                                    .Select(v => new {
                                        v.ReferringAuthorityId
                                        , v.ReferringAuthorityName
                                        , v.DORSForceId
                                        , v.DORSForceIdentifier
                                        , v.DORSForceName
                                        , v.DORSForcePNCCode
                                        , Visible = true
                                    })
                                    .ToList()
                                    .OrderBy(w => w.ReferringAuthorityName);
                        return referringAuthorityList;
                    }
                            catch (Exception ex)
                    {
                        return null;
                    }
                    break;
                case "CourseType":
                    try
                    {
                        var courseTypeList = atlasDBViews.vwReportsCourseTypes
                                    .Where(x => x.OrganisationId == organisationId)
                                    .DefaultIfEmpty()
                                    .Select(v => new
                                    {
                                        v.Id
                                        , v.Title
                                        , v.Code
                                        , v.Description
                                        , v.DORSOnly
                                        , Visible = true
                                    })
                                    .ToList()
                                    .OrderBy(w => w.Title);
                        return courseTypeList;
                    }
                            catch (Exception ex)
                    {
                        return null;
                    }
                    break;
                case "PaymentMethod":
                    try
                    {
                        var paymentMethodList = atlasDBViews.vwReportsPaymentMethods
                                    .Where(x => x.OrganisationId == organisationId)
                                    .DefaultIfEmpty()
                                    .Select(v => new
                                    {
                                        v.Id
                                        , v.Name
                                        , v.Description
                                        , v.Code
                                        , v.Disabled
                                        , Visible = true
                                    })
                                    .ToList()
                                    .OrderBy(w => w.Name);
                        return paymentMethodList;
                    }
                            catch (Exception ex)
                    {
                        return null;
                    }
                    break;
                case "CoursesRecentFuture":
                    try
                    {
                        var coursesRecentFutureList = atlasDBViews.vwCourseListRecentAndFutures
                                    .Where(x => x.OrganisationId == organisationId)
                                    .DefaultIfEmpty()
                                    .Select(v => new
                                    {
                                        v.CourseId
                                        , v.CourseIdentity
                                        , v.CourseType
                                        , v.CourseTypeCode
                                        , v.CourseStartDate
                                        , Visible = true
                                    })
                                    .ToList()
                                    .OrderBy(w => w.CourseStartDate);
                        return coursesRecentFutureList;
                    }
                    catch (Exception ex)
                    {
                        return null;
                    }
                    break;
                case "CoursesPast":
                    try
                    {
                        var coursesPastList = atlasDBViews.vwCourseListPasts
                                    .Where(x => x.OrganisationId == organisationId)
                                    .DefaultIfEmpty()
                                    .Select(v => new
                                    {
                                        v.CourseId
                                        , v.CourseIdentity
                                        , v.CourseType
                                        , v.CourseTypeCode
                                        , v.CourseStartDate
                                        , Visible = true
                                    })
                                    .ToList()
                                    .OrderByDescending(w => w.CourseStartDate);
                        return coursesPastList;
                    }
                    catch (Exception ex)
                    {
                        return null;
                    }
                    break;
                default:
                    return new object();
                    break;
            }
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/report/getReportsDefaults")]
        public object getReportsDefaults()
        {
            var reportsDefaults = atlasDBViews
                                    .vwReportDefaults
                                    .ToList();

            return reportsDefaults;
        }

        [AuthorizationRequired]
        [HttpGet]
        [Route("api/report/getReportDetail/{reportId}")]
        public object getReportDetail(int reportId)
        {
            var reportDetail = atlasDBViews
                                    .vwReportDetails
                                    .Where(x => x.ReportId == reportId)
                                    .DefaultIfEmpty()
                                    .ToList();

            return reportDetail;
        }

        private class ReportData
        {
            public int ReportId { get; set; }
            public int ReportRequestId { get; set; }
            public string ReportClass { get; set; }
            public int NumberOfDataColumns { get; set; }
            public bool DataEndRow { get; set; }
            public string C1 { get; set; }
            public string C2 { get; set; }
            public string C3 { get; set; }
            public string C4 { get; set; }
            public string C5 { get; set; }
            public string C6 { get; set; }
            public string C7 { get; set; }
            public string C8 { get; set; }
            public string C9 { get; set; }
            public string C10 { get; set; }
            public string C11 { get; set; }
            public string C12 { get; set; }
            public string C13 { get; set; }
            public string C14 { get; set; }
            public string C15 { get; set; }
            public string C16 { get; set; }
            public string C17 { get; set; }
            public string C18 { get; set; }
            public string C19 { get; set; }
            public string C20 { get; set; }
            public string C21 { get; set; }
            public string C22 { get; set; }
            public string C23 { get; set; }
            public string C24 { get; set; }
            public string C25 { get; set; }
            public string C26 { get; set; }
            public string C27 { get; set; }
            public string C28 { get; set; }
            public string C29 { get; set; }
            public string C30 { get; set; }
            public long RowOrder { get; set; }
        }

        private List<parameterOption> GetOrganisationParameterOptions(string parameterType, int organisationId)
        {
            switch (parameterType)
            {
                case "CourseType":
                case "CourseTypeMultiple":
                    return atlasDB.CourseType
                   .Where(x => x.OrganisationId == organisationId)
                   .Select(x => new parameterOption
                   {
                       optionId = x.Id,
                       optionDescription = x.Title
                   })
                   .ToList();

                case "CourseTypeCategory":
                case "CourseTypeCategoryMultiple":
                    return atlasDB.CourseTypeCategories
                        .Include(x => x.CourseType)
                   .Where(x => x.CourseType.OrganisationId == organisationId)
                   .Select(x => new parameterOption
                   {
                       optionId = x.Id,
                       optionDescription = x.Name
                   })
                   .ToList();

                case "PaymentMethod":
                case "PaymentMethodMultiple":
                    return atlasDB.PaymentMethod
                   .Where(x => x.OrganisationId == organisationId)
                   .Select(x => new parameterOption
                   {
                       optionId = x.Id,
                       optionDescription = x.Name
                   })
                   .ToList();

                case "PaymentType":
                case "PaymentTypeMultiple":
                    return atlasDB.OrganisationPaymentType
                        .Include(x => x.PaymentType)
                   .Where(x => x.OrganisationId == organisationId)
                   .Select(x => new parameterOption
                   {
                       optionId = x.Id,
                       optionDescription = x.PaymentType.Name
                   })
                   .ToList();

                case "PaymentProvider":
                case "PaymentProviderMultiple":
                   // @Todo: PaymentProvider - Commented out
                   // return atlasDB.PaymentProvider
                   //.Where(x => x.OrganisationId == organisationId)
                   //.Select(x => new parameterOption
                   //{
                   //    optionId = x.Id,
                   //    optionDescription = x.Name
                   //})
                   //.ToList();

                default: return null;
            }
        }

        class ColumnOrderAndSortByOrderLists
        {
            public int Id { get; set; }
            public List<ReportDataGridColumn> columnOrder { get; set; }
            public List<ReportDataGridColumn> columnSortByOrder { get; set; }
        }

        class CloneData
        {
            public int sourceReportID { get; set; }
            public int userID { get; set; }
            public string cloneReportTitle { get; set; }
            public string cloneReportDescription { get; set; }
        }
        
        #region Class definitions required for returning report parameter data

        public class ReportAttributes
        {
            public int reportId { get; set; }
            public string reportTitle { get; set; }
            public string reportDescription { get; set; }
            public List<singleParameter> inputParameters { get; set; }
        }

        public class singleParameter
        {
            public int parameterId { get; set; }
            public string parameterTitle { get; set; }
            public string parameterType { get; set; }
            public List<parameterOption> parameterOptions { get; set; }
        }

        public class parameterOption
        {
            public int optionId { get; set; }
            public string optionDescription { get; set; }
        }

        #endregion
    }


}