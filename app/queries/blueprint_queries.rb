class BlueprintQueries
  def self.discussed(blueprints)
    comment_counts = Comment.unscoped
      .select('blueprint_id, COUNT(*) as comments_count')
      .group('blueprint_id')
      .to_sql
    
    blueprints.joins("LEFT JOIN (#{comment_counts}) AS comment_counts ON comment_counts.blueprint_id = blueprints.id")
      .select('blueprints.*, COALESCE(comment_counts.comments_count, 0) as comments_count')
      .reorder('comments_count DESC')
  end
end 