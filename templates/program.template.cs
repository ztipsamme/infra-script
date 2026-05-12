using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

if (!builder.Environment.IsDevelopment())
{
    builder.Services.AddApplicationInsightsTelemetry();
}

var connString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddDbContext<Labb1Context>(options =>
    options.UseSqlServer(connString));

builder.Services.AddOpenApi();

var app = builder.Build();

app.MapToDoEndpoints();
// app.MapUserEndpoints();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

using (var scope = app.Services.CreateScope())
{
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    logger.LogInformation("🚀 App is fully starting (after build)");

    var db = scope.ServiceProvider.GetRequiredService<Labb1Context>();

    logger.LogInformation("DB Connection exists: {hasConn}", !string.IsNullOrEmpty(connString));

    if (app.Environment.IsDevelopment())
    {
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
}

app.Run();


// SEEDER
public static class DbSeeder
{
    public static void Seed(Labb1Context db)
    {
        if (db.Todos.Any()) return;

        db.Todos.AddRange(
            new ToDo { Title = "Lär mig Azure 🚀" },
            new ToDo { Title = "Deploya API" },
            new ToDo { Title = "Fixa VG-nivå 😉" }
        );

        db.SaveChanges();
    }
}


// ENTITY
public class ToDo
{
    public int Id { get; set; }
    public string Title { get; set; } = "";
}

// public class User
// {
//     public int Id { get; set; }
//     public string Name { get; set; } = "";
// }


// ENDPOINTS
public static class ToDoEndpoints
{
    public static void MapToDoEndpoints(this WebApplication app)
    {
        var toDoGroup = app.MapGroup($"/api/todos");

        toDoGroup.MapGet("", Get);
        toDoGroup.MapPost("", Create);
        toDoGroup.MapGet("{id:int}", GetById);
    }

    private static async Task<Ok<List<ToDo>>> Get(
        Labb1Context db,
        ILogger<Program> logger)
    {
        logger.LogInformation("GET /todos called");

        var todos = await db.Todos.ToListAsync();

        logger.LogInformation("Returned {count} todos", todos.Count);

        return TypedResults.Ok(todos);
    }

    private static async Task<Created<ToDo>> Create(
        ToDo todo,
        Labb1Context db,
        ILogger<Program> logger)
    {
        logger.LogInformation("POST /todos called");

        db.Todos.Add(todo);
        await db.SaveChangesAsync();

        return TypedResults.Created($"/todos/{todo.Id}", todo);
    }

    private static async Task<Results<Ok<ToDo>, NotFound>> GetById(
        int id,
        Labb1Context db,
        ILogger<Program> logger)
    {
        logger.LogInformation($"GET /todo/{id} called");

        var toDo = await db.Todos.
            Where(t => t.Id == id).
            FirstOrDefaultAsync();

        return toDo != null ? TypedResults.Ok(toDo) : TypedResults.NotFound();
    }
}

// public static class UserEndpoints
// {
//     public static void MapUserEndpoints(this WebApplication app)
//     {
//         var userGroup = app.MapGroup($"/api/users");

//         userGroup.MapGet("", Get);
//         userGroup.MapPost("", Create);
//     }

//     private static async Task<Ok<List<User>>> Get(
//         Labb1Context db,
//         ILogger<Program> logger)
//     {
//         logger.LogInformation("GET /users called");

//         var users = await db.Users.ToListAsync();

//         logger.LogInformation("Returned {count} users", users.Count);

//         return TypedResults.Ok(users);
//     }

//     private static async Task<Created<User>> Create(
//         User user,
//         Labb1Context db,
//         ILogger<Program> logger)
//     {
//         logger.LogInformation("POST /users called");

//         db.Users.Add(user);
//         await db.SaveChangesAsync();

//         return TypedResults.Created($"/users/{user.Id}", user);
//     }
// }



// DB CONTEXT
public class Labb1Context : DbContext
{
    public Labb1Context(DbContextOptions<Labb1Context> options)
        : base(options)
    {
    }

    public DbSet<ToDo> Todos => Set<ToDo>();
    // public DbSet<User> Users => Set<User>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
    }
}
