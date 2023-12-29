-- 1. How many times does the average user post?
      select round(count(*)/count(distinct u.id)) avg_postby_users from users u 
      left join photos p on u.id=p.user_id;
-- 2.  Find the top 5 most used hashtags
       select count(*) no_of_times_hashtags_used, tag_name from tags
       join photo_tags t on tags.id=t.tag_id group by tag_name order by 1 desc limit 5;

-- 3. Find users who have liked every single photo on the site
select  u.id,u.username,count(l.photo_id)  from users u join likes l
 on u.id=l.user_id group by u.id having select count(l.photo_id) =(select count(distinct photo_id) from likes);

-- 4. Retrieve a list of users along with their usernames and the rank of their account creation, 
-- ordered by the creation date in ascending order.
select username,dense_rank() over(order by created_at asc) as acc_creation_rank
 from users order by created_at;

-- 5. List the comments made on photos with their comment texts, photo URLs, and usernames of users
-- who posted the comments. Include the comment count for each photo.
 select comments.comment_text,
 photos.image_url,
 users.username,
 (select count(*) from comments where comments.photo_id=photos.id) as comments_count from comments
 join users on comments.user_id = users.id
 join photos on photos.id=comments.photo_id
 order by comments_count desc;
 
  
 
  
 -- 6.  For each tag, show the tag name and the number of photos associated with that tag.
-- Rank the tags by the number of photos in descending order. 
	  select t.tag_name,count(user_id) no_of_times_hashtags_used,rank()
	  over(order by count(user_id) desc) as photo_count 
      from photos p join tags t on p.user_id=t.id group by tag_name order by 1 desc ;
  
  -- 7. List the usernames of users who have posted photos along with the count of photos they have posted.
--  Rank them by the number of photos in descending order.
   select u.id,u.username,count(*) as count_of_photos,
   dense_rank() over(order by count(*) desc) no_of_photos_desc_order 
   from users u join photos p on u.id=p.user_id group by u.id;


-- 8. Display the username of each user along with the creation date of their first posted photo and the creation date of their next posted photo.
 with ss as (
 select u.id,u.username,p.created_at as first_posted_photo,
 row_number() over(partition by u.id order by p.created_at) rank2 
 from users u join photos p on u.id=p.user_id order by p.created_at asc)
select id,username,first_posted_photo,second_posted_photo
from ( select * , lead(first_posted_photo) over(partition by id ) second_posted_photo from ss) ww where rank2 =1;

-- 9. For each comment, show the comment text, the username of the commenter, and the comment text of the previous comment made on the same photo.
   select u.username,c.comment_text,
   lag(c.comment_text) over( partition by photo_id )as previous_comment
   from comments c join users u on c.user_id = u.id order by photo_id;

 -- 10. Show the username of each user along with the number of photos they have posted and the number of photos 
 -- posted by the user before them and after them, based on the creation date.
 
 select u.id,u.username,count(p.id)as no_of_post,lag(count(p.id)) over() as previous_post,
lead(count(p.id)) over() as next_post from users u join photos p on u.id=p.user_id 
group by u.id ;
 