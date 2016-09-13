using ArgonneWebApi.Repositories;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Serialization;
using Microsoft.AspNetCore.Diagnostics;
using System.Net;
using Microsoft.AspNetCore.Http;
using ArgonneWebApi.Models.Datastore;
using ArgonneWebApi.Models.Mapping;
using AutoMapper;
using Swashbuckle.Swagger.Model;
using Microsoft.Extensions.PlatformAbstractions;


namespace ArgonneWebApi
{
    public class Startup
    {
        public Startup(IHostingEnvironment env)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true)
                .AddEnvironmentVariables();

            if (env.IsDevelopment())
            {
                // For more details on using the user secret store see http://go.microsoft.com/fwlink/?LinkID=532709
                builder.AddUserSecrets();

                builder.AddApplicationInsightsSettings(developerMode: true);
            }


            Configuration = builder.Build();
        }

        public IConfigurationRoot Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.ConfigureSwaggerGen(options =>
            {
                options.SingleApiVersion(new Info
                {
                    Version = "v1",
                    Title = "Argonne API",
                    Description = "REST services for Project Argonne",
                    TermsOfService = "See Microsoft IOT Lab TOS",
                    Contact = new Contact { Name = "Microsoft IOT Insider Lab", Email = "iotinsider@microsoft.com", Url = "https://microsoft.com/en-us/iotinsider" },
                    License = new License { Name = "MIT", Url = "https://opensource.org/licenses/MIT" }
                });

                //Determine base path for the application.
                var basePath = PlatformServices.Default.Application.ApplicationBasePath;

                //Set the comments path for the swagger json and ui.
                options.IncludeXmlComments(basePath + "\\ArgonneWebApi.xml");
            });


            // Inject an implementation of ISwaggerProvider with defaulted settings applied
            services.AddSwaggerGen();

            services.AddAutoMapper();

            // Add framework services.
            services.AddApplicationInsightsTelemetry(Configuration);

            services.AddDbContext<ArgonneDbContext>(options => options.UseSqlServer(Configuration["ArgonneDbConnectionString"]));

            services.AddScoped<IEntityRepository<Devices>, EntityRepository<Devices>>();
            services.AddScoped<IEntityRepository<Campaigns>, EntityRepository<Campaigns>>();
            services.AddScoped<IEntityRepository<Ads>, EntityRepository<Ads>>();
            services.AddScoped<IEntityRepository<Impressions>, EntityRepository<Impressions>>();
            services.AddScoped<IEntityRepository<AdsForCampaigns>, EntityRepository<AdsForCampaigns>>();
            services.AddScoped<IEntityRepository<FacesForImpressions>, EntityRepository<FacesForImpressions>>();
            services.AddScoped<IArgonneQueryContext, EntityRepository<Campaigns>>();
            // Automapper Configuration
            AutoMapperConfiguration.Configure();

            // Enable Cors
            services.AddCors();
            // Add framework services.
            services.AddMvc().AddJsonOptions(a => a.SerializerSettings.ContractResolver = new CamelCasePropertyNamesContractResolver());
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory)
        {
            app.UseDeveloperExceptionPage();

            loggerFactory.AddConsole(Configuration.GetSection("Logging"));
            loggerFactory.AddDebug();

            app.UseMvc();

            // Add MVC to the request pipeline.
            app.UseCors(builder =>
                builder.AllowAnyOrigin()
                .AllowAnyHeader()
                .AllowAnyMethod());

            // Enable middleware to serve generated Swagger as a JSON endpoint
            app.UseSwagger();

            // Enable middleware to serve swagger-ui assets (HTML, JS, CSS etc.)
            app.UseSwaggerUi();


            //TODO: top level exception handler should log to application insights? Using Serilog?

            //app.UseExceptionHandler(
            //  builder =>
            //  {
            //      builder.Run(
            //        async context =>
            //        {
            //            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            //            context.Response.Headers.Add("Access-Control-Allow-Origin", "*");

            //            var error = context.Features.Get<IExceptionHandlerFeature>();
            //            if (error != null)
            //            {
            //                //context.Response.AddApplicationError(error.Error.Message);
            //                await context.Response.WriteAsync(error.Error.Message).ConfigureAwait(false);
            //            }
            //        });
            //  });
        }
    }
}
