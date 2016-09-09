using ArgonneWebApi.Models.Datastore;
using Microsoft.EntityFrameworkCore;


namespace ArgonneWebApi.Repositories
{
    public partial class ArgonneDbContext : DbContext
    {
        public ArgonneDbContext(DbContextOptions options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Ads>(entity =>
            {
                entity.HasKey(e => e.AdId)
                    .HasName("PK_Advertisements");

                entity.HasIndex(e => e.AdName)
                    .HasName("IX_Ads_Name");

                entity.Property(e => e.AdId).ValueGeneratedNever();

                entity.Property(e => e.AdName)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.Property(e => e.Url)
                    .IsRequired()
                    .HasColumnName("URL")
                    .HasMaxLength(200);
            });

            modelBuilder.Entity<AdsForCampaigns>(entity =>
            {
                entity.HasKey(e => new { e.CampaignId, e.AdId })
                    .HasName("PK_AdsForCampaigns");

                entity.HasOne(d => d.Ad)
                    .WithMany(p => p.AdsForCampaigns)
                    .HasForeignKey(d => d.AdId)
                    .HasConstraintName("FK_AdsForCampaigns_Ads");

                entity.HasOne(d => d.Campaign)
                    .WithMany(p => p.AdsForCampaigns)
                    .HasForeignKey(d => d.CampaignId)
                    .HasConstraintName("FK_AdsForCampaigns_Campaigns");
            });

            modelBuilder.Entity<BiasesForDevices>(entity =>
            {
                entity.HasKey(e => e.DeviceId)
                    .HasName("PK_BiasesForDevices");

                entity.Property(e => e.DeviceId).ValueGeneratedNever();

                entity.Property(e => e.AngerBias).HasDefaultValueSql("0.125");

                entity.Property(e => e.ContemptBias).HasDefaultValueSql("0.125");

                entity.Property(e => e.CountBias).HasDefaultValueSql("1");

                entity.Property(e => e.DisgustBias).HasDefaultValueSql("0.125");

                entity.Property(e => e.FearBias).HasDefaultValueSql("0.125");

                entity.Property(e => e.HappinessBias).HasDefaultValueSql("0.125");

                entity.Property(e => e.NeutralBias).HasDefaultValueSql("0.125");

                entity.Property(e => e.SadnessBias).HasDefaultValueSql("0.125");

                entity.Property(e => e.ShadowName)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.Property(e => e.SurpriseBias).HasDefaultValueSql("0.125");

                entity.HasOne(d => d.Device)
                    .WithOne(p => p.BiasesForDevices)
                    .HasForeignKey<BiasesForDevices>(d => d.DeviceId)
                    .HasConstraintName("FK_BiasesForDevices_Devices");
            });

            modelBuilder.Entity<Campaigns>(entity =>
            {
                entity.HasKey(e => e.CampaignId)
                    .HasName("PK_Campaigns");

                entity.Property(e => e.CampaignId).ValueGeneratedNever();

                entity.Property(e => e.CampaignName)
                    .IsRequired()
                    .HasMaxLength(100);
            });

            modelBuilder.Entity<Devices>(entity =>
            {
                entity.HasKey(e => e.DeviceId)
                    .HasName("PK_Devices");

                entity.HasOne(d => d.CurrentCampaign)
                    .WithMany(p => p.Devices)
                    .HasForeignKey(d => d.AssignedCampaignId)
                    .HasConstraintName("FK_Devices_Campaigns");

                entity.HasIndex(e => e.PostalCode)
                    .HasName("IX_Devices_PostalCode");

                entity.Property(e => e.DeviceId).ValueGeneratedNever();

                entity.Property(e => e.Address)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.Property(e => e.Address2)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.Property(e => e.Address3)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.Property(e => e.City)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.Property(e => e.DeviceName)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.Property(e => e.PostalCode)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.PrimaryKey)
                    .IsRequired()
                    .HasMaxLength(100);

                entity.Property(e => e.StateProvince)
                    .IsRequired()
                    .HasMaxLength(50);
            });

            modelBuilder.Entity<ErrorLog>(entity =>
            {
                entity.HasKey(e => e.Timestamp)
                    .HasName("PK_ErrorLog");

                entity.Property(e => e.Timestamp)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("getdate()");

                entity.Property(e => e.Error)
                    .IsRequired()
                    .HasMaxLength(200);

                entity.Property(e => e.Json)
                    .IsRequired()
                    .HasColumnName("JSON");
            });

            modelBuilder.Entity<FacesForImpressions>(entity =>
            {
                entity.HasKey(e => new { e.ImpressionId, e.Sequence })
                    .HasName("PK_FacesForImpressions");

                entity.HasIndex(e => e.Age)
                    .HasName("IX_FacesForImpressions_Age");

                entity.HasIndex(e => e.FaceId)
                    .HasName("IX_FacesForImpressions_FaceId");

                entity.Property(e => e.FaceId)
                    .IsRequired()
                    .HasMaxLength(50);

                entity.Property(e => e.Gender)
                    .IsRequired()
                    .HasMaxLength(12);

                entity.Property(e => e.ScoreAnger).HasColumnType("decimal");

                entity.Property(e => e.ScoreContempt).HasColumnType("decimal");

                entity.Property(e => e.ScoreDisgust).HasColumnType("decimal");

                entity.Property(e => e.ScoreFear).HasColumnType("decimal");

                entity.Property(e => e.ScoreHappiness).HasColumnType("decimal");

                entity.Property(e => e.ScoreNeutral).HasColumnType("decimal");

                entity.Property(e => e.ScoreSadness).HasColumnType("decimal");

                entity.Property(e => e.ScoreSurprise).HasColumnType("decimal");

                entity.HasOne(d => d.Impression)
                    .WithMany(p => p.FacesForImpressions)
                    .HasForeignKey(d => d.ImpressionId)
                    .HasConstraintName("FK_FacesForImpressions_Impressions");
            });

            modelBuilder.Entity<Impressions>(entity =>
            {
                entity.HasKey(e => e.ImpressionId)
                    .HasName("PK_Impressions");

                entity.HasIndex(e => e.DeviceId)
                    .HasName("IX_Impressions_DeviceId");

                entity.HasIndex(e => e.DeviceTimestamp)
                    .HasName("IX_Impressions_DeviceTimestamp");

                entity.HasIndex(e => e.DisplayedAdId)
                    .HasName("IX_Impressions_DisplayedAdId");

                entity.HasIndex(e => e.MessageId)
                    .HasName("IX_Impressions_MessageId");

                entity.Property(e => e.DeviceTimestamp).HasColumnType("datetime");

                entity.Property(e => e.InsertTimestamp)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("getdate()");

                entity.HasOne(d => d.Device)
                    .WithMany(p => p.Impressions)
                    .HasForeignKey(d => d.DeviceId)
                    .HasConstraintName("FK_Impressions_Devices");

                entity.HasOne(d => d.DisplayedAd)
                    .WithMany(p => p.Impressions)
                    .HasForeignKey(d => d.DisplayedAdId)
                    .HasConstraintName("FK_Impressions_Ads");

                entity.HasOne(d => d.Campaign)
                    .WithMany(p => p.Impressions)
                    .HasForeignKey(d => d.CampaignId)
                    .HasConstraintName("FK_Impressions_Campaigns");
            });
        }

        public virtual DbSet<Ads> Ads { get; set; }
        public virtual DbSet<AdsForCampaigns> AdsForCampaigns { get; set; }
        public virtual DbSet<BiasesForDevices> BiasesForDevices { get; set; }
        public virtual DbSet<Campaigns> Campaigns { get; set; }
        public virtual DbSet<Devices> Devices { get; set; }
        public virtual DbSet<ErrorLog> ErrorLog { get; set; }
        public virtual DbSet<FacesForImpressions> FacesForImpressions { get; set; }
        public virtual DbSet<Impressions> Impressions { get; set; }
    }
}