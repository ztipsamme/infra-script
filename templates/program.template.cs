using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationInsightsTelemetry();

var connString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<Labb1Context>(options =>
    options.UseSqlServer(connString));

builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.MapGet("/todos", async (Labb1Context db, ILogger<Program> logger) =>
{
    logger.LogInformation("GET /todos called");

    var todos = await db.Todos.ToListAsync();

    logger.LogInformation("Returned {count} todos", todos.Count);

    return todos;
});

using (var scope = app.Services.CreateScope())
{
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    logger.LogInformation("🚀 App is fully starting (after build)");

    var db = scope.ServiceProvider.GetRequiredService<Labb1Context>();

    logger.LogInformation("DB Connection exists: {hasConn}", !string.IsNullOrEmpty(connString));

    try
    {
        logger.LogInformation("➡️ Starting DB migration...");
        db.Database.Migrate();
        logger.LogInformation("DB migration completed");

        logger.LogInformation("🌱 Seeding database...");
        DbSeeder.Seed(db);
        logger.LogInformation("Seeding completed");
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "❌ DB init failed");
    }
}

app.Run();


// SEEDER
public static class DbSeeder
{
    public static void Seed(Labb1Context db)
    {
        if (db.Todos.Any()) return;

        db.Todos.AddRange(
            new Todo { Title = "Lär mig Azure 🚀" },
            new Todo { Title = "Deploya API" },
            new Todo { Title = "Fixa VG-nivå 😉" }
        );

        db.SaveChanges();
    }
}


// ENTITY
public class Todo
{
    public int Id { get; set; }
    public string Title { get; set; } = "";
}


// DB CONTEXT
public class Labb1Context : DbContext
{
    public Labb1Context(DbContextOptions<Labb1Context> options)
        : base(options)
    {
    }

    public DbSet<Todo> Todos => Set<Todo>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
    }
}