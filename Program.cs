using coffee_shop;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

public partial class Program
{
    private static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // ── Services ─────────────────────────────────────
        builder.Services.AddRazorPages(options => options.RootDirectory = "/frontend");
        builder.Services.AddControllers();
        builder.Services.AddSingleton<Dbhelper>();
        builder.Services.AddEndpointsApiExplorer();

        // ── JWT Authentication ────────────────────────────
        var jwtKey = builder.Configuration["Jwt:Key"];
        if (string.IsNullOrWhiteSpace(jwtKey))
            throw new InvalidOperationException("Configuration missing: Jwt:Key.");

        builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(opt =>
            {
                opt.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
                    ValidateIssuer = true,
                    ValidIssuer = builder.Configuration["Jwt:Issuer"],
                    ValidateAudience = true,
                    ValidAudience = builder.Configuration["Jwt:Audience"],
                    ValidateLifetime = true
                };
            });

        // ── CORS ──────────────────────────────────────────
        builder.Services.AddCors(opt => opt.AddPolicy("AllowFrontend", p =>
            p.AllowAnyOrigin()
             .AllowAnyHeader()
             .AllowAnyMethod()));

        var app = builder.Build();

        // ── Middleware ────────────────────────────────────
        if (app.Environment.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }

        app.UseHttpsRedirection();
        app.UseStaticFiles();
        app.UseRouting();
        app.UseCors("AllowFrontend");
        app.UseAuthentication();
        app.UseAuthorization();

        app.MapRazorPages();
        app.MapControllers();

        app.Run();
    }
}