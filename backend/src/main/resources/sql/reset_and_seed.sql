-- ============================================================
-- SoccerHub 数据重置脚本
-- 功能: 清空旧数据 + 重新插入新数据
-- 使用前请确保已执行第0步（禁用外键、清空、重置序列、启用外键）
-- ============================================================

-- 关闭外键约束检查（如果存在）
-- ALTER TABLE PLAYER DISABLE CONSTRAINT FK_PLAYER_CLUB;
-- ALTER TABLE COACH DISABLE CONSTRAINT FK_COACH_CLUB;
-- ALTER TABLE MATCH_SCHEDULE DISABLE CONSTRAINT FK_MATCH_HOME;
-- ALTER TABLE MATCH_SCHEDULE DISABLE CONSTRAINT FK_MATCH_AWAY;
-- ALTER TABLE LEAGUE_STANDINGS DISABLE CONSTRAINT FK_STANDINGS_CLUB;

-- ============================================================
-- 第0步: 跳过（数据已通过上方 SQL 重置）
-- ============================================================
-- 本脚本仅包含 INSERT 数据，如需重新执行直接运行即可

-- ============================================================
-- 第1部分: 俱乐部数据 (25支)
-- ============================================================

-- 英超 (Premier League)
INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Arsenal', '阿森纳', 'Premier League', 'London', 'England', 'Emirates Stadium', TO_DATE('1886-01-01', 'YYYY-MM-DD'), 60704,
'阿森纳足球俱乐部，成立于1886年，是英格兰足球超级联赛的创始成员之一。俱乐部位于伦敦，主场为能容纳6万多人的酋长球场。阿森纳以其华丽的传控打法闻名，历史上曾13次夺得英格兰顶级联赛冠军。球队以青训体系著称，培养出众多世界级球星。', 8.7);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Manchester City', '曼城', 'Premier League', 'Manchester', 'England', 'Etihad Stadium', TO_DATE('1894-01-01', 'YYYY-MM-DD'), 53400,
'曼城足球俱乐部，成立于1894年，近年来在石油资本的加持下成为欧洲最具统治力的球队之一。主场为伊蒂哈德球场，2022-23赛季更是在瓜迪奥拉带领下实现了英超、足总杯、欧冠的三冠王伟业。球队以精准的传控打法和强大的阵容深度著称。', 9.2);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Manchester United', '曼联', 'Premier League', 'Manchester', 'England', 'Old Trafford', TO_DATE('1878-01-01', 'YYYY-MM-DD'), 74310,
'曼彻斯特联足球俱乐部，成立于1878年，是英格兰乃至世界足坛最成功的俱乐部之一。主场为拥有"梦剧场"美誉的老特拉福德球场，可容纳近75000人。曼联曾20次夺得英格兰顶级联赛冠军，3次赢得欧冠冠军，以"红魔"之名享誉全球。', 8.3);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Chelsea', '切尔西', 'Premier League', 'London', 'England', 'Stamford Bridge', TO_DATE('1905-01-01', 'YYYY-MM-DD'), 40343,
'切尔西足球俱乐部，成立于1905年，主场为伦敦的斯坦福桥球场。俱乐部在21世纪迎来黄金期，在阿布拉莫维奇时代多次夺得英超和欧冠冠军。切尔西以稳健的防守和强大的财力闻名，是英格兰足坛的蓝色豪门。', 8.5);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Liverpool', '利物浦', 'Premier League', 'Liverpool', 'England', 'Anfield', TO_DATE('1892-01-01', 'YYYY-MM-DD'), 53394,
'利物浦足球俱乐部，成立于1892年，是英格兰最具传奇色彩的俱乐部之一。主场为著名的安菲尔德球场，球迷高唱的"你永远不会独行"已成为足球文化经典。利物浦6次夺得欧冠冠军，19次赢得英格兰联赛冠军，以永不放弃的拼搏精神著称。', 8.9);

-- 西甲 (La Liga)
INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('FC Barcelona', '巴萨', 'La Liga', 'Barcelona', 'Spain', 'Estadi Olímpic Lluís Companys', TO_DATE('1899-01-01', 'YYYY-MM-DD'), 99454,
'巴塞罗那足球俱乐部，成立于1899年，是西班牙乃至世界足坛的超级豪门。主场为拥有近10万座席的诺坎普球场，是全欧洲最大的球场之一。巴塞罗那以"tiki-taka"传控打法闻名，队史获得超过25次西甲冠军和5次欧冠冠军，与死敌皇马的"国家德比"是世界足坛最受关注的比赛。', 8.8);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Real Madrid', '皇家马德里', 'La Liga', 'Madrid', 'Spain', 'Santiago Bernabéu', TO_DATE('1902-01-01', 'YYYY-MM-DD'), 81044,
'皇家马德里足球俱乐部，成立于1902年，被公认为世界足坛最伟大的俱乐部。主场为伯纳乌球场，拥有超过80年辉煌历史。皇马15次夺得欧冠冠军（历史之最），35次问鼎西甲联赛。俱乐部以"银河战舰"策略著称，吸引了无数世界顶级球星加盟。', 9.1);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Villarreal CF', '比利亚雷亚尔', 'La Liga', 'Villarreal', 'Spain', 'Estadio de la Cerámica', TO_DATE('1923-01-01', 'YYYY-MM-DD'), 24896,
'比利亚雷亚尔足球俱乐部，成立于1923年，来自西班牙瓦伦西亚自治区的小城比利亚雷亚尔。球队主场为陶瓷球场，以鲜明的黄色队徽闻名。尽管规模不大，但黄色潜水艇在欧洲赛场表现惊艳，2020-21赛季更是在埃梅里带领下勇夺欧联杯冠军。', 7.6);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Atlético Madrid', '马德里竞技', 'La Liga', 'Madrid', 'Spain', 'Cívitas Metropolitano', TO_DATE('1903-01-01', 'YYYY-MM-DD'), 68456,
'马德里竞技足球俱乐部，成立于1903年，是西班牙首都马德里的另一支豪门球队。主场为大都会球场，是目前西班牙容量最大的球场之一。马竞以铁血防守和顽强斗志著称，在迭戈·西蒙尼的长期执教下成为欧洲最具竞争力的球队之一，两次打进欧冠决赛。', 8.4);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Real Sociedad', '皇家社会', 'La Liga', 'San Sebastián', 'Spain', 'Anoeta Stadium', TO_DATE('1909-01-01', 'YYYY-MM-DD'), 39650,
'皇家社会足球俱乐部，成立于1909年，位于西班牙北部巴斯克地区的圣塞巴斯蒂安。球队主场为Anoeta球场，以精湛的技术流打法著称。皇家社会曾两次夺得西甲联赛冠军，近年来持续位居联赛中上游，是巴斯克地区足球的代表之一。', 7.5);

-- 法甲 (Ligue 1)
INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Paris Saint-Germain', '巴黎圣日', 'Ligue 1', 'Paris', 'France', 'Parc des Princes', TO_DATE('1970-01-01', 'YYYY-MM-DD'), 47929,
'巴黎圣日耳曼足球俱乐部，成立于1970年，是法国足坛的绝对霸主。主场为王子公园球场，位于巴黎西部。俱乐部自2011年被卡塔尔体育投资公司收购后，成为欧洲转会市场上最活跃的俱乐部之一，签下过内马尔、姆巴佩、梅西等众多世界级球星，目标直指欧冠冠军。', 8.7);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Olympique Lyon', '里昂', 'Ligue 1', 'Lyon', 'France', 'Groupama Stadium', TO_DATE('1950-01-01', 'YYYY-MM-DD'), 59186,
'里昂足球俱乐部，成立于1950年，是法国足球传统强队。主场为能容纳近6万人的Groupama体育场。里昂曾在2002至2008年间创纪录地连续7次夺得法甲联赛冠军，培养出本泽马、费等众多顶级球星，是法国乃至欧洲最重要的青训基地之一。', 7.8);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('AS Monaco', '摩纳哥', 'Ligue 1', 'Monaco', 'Monaco', 'Stade Louis II', TO_DATE('1924-01-01', 'YYYY-MM-DD'), 18523,
'摩纳哥足球俱乐部，成立于1924年，位于地中海袖珍公国摩纳哥。主场为路易二世体育场，是欧洲最小的顶级联赛主场之一。尽管体量不大，摩纳哥以"欧洲黑店"著称，擅长发掘和培养年轻球员并高价出售，曾8次夺得法甲联赛冠军。', 7.7);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Olympique Marseille', '马赛', 'Ligue 1', 'Marseille', 'France', 'Stade Vélodrome', TO_DATE('1899-01-01', 'YYYY-MM-DD'), 67394,
'马赛奥林匹克足球俱乐部，成立于1899年，是法国最古老和最受欢迎的足球俱乐部之一。主场为韦洛德罗姆球场，是法国最大的俱乐部球场之一。马赛是唯一一支夺得过欧冠冠军的法国球队（1993年），与巴黎圣日耳曼的"国家德比"是法国足坛最火爆的对决。', 7.9);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Stade Rennais', '雷恩', 'Ligue 1', 'Rennes', 'France', 'Roazhon Park', TO_DATE('1901-01-01', 'YYYY-MM-DD'), 29778,
'雷恩足球俱乐部，成立于1901年，来自法国布列塔尼地区的首府雷恩。主场为Roazhon公园球场。雷恩是法国足坛的中坚力量，近年来凭借出色的青训体系逐渐崛起，曾在2019年获得法国杯冠军。球队以年轻化和积极的比赛风格著称。', 7.4);

-- 德甲 (Bundesliga)
INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Bayern Munich', '拜仁慕尼黑', 'Bundesliga', 'Munich', 'Germany', 'Allianz Arena', TO_DATE('1900-01-01', 'YYYY-MM-DD'), 75000,
'拜仁慕尼黑足球俱乐部，成立于1900年，是德国乃至欧洲最成功的足球俱乐部。主场为标志性的安联竞技场，外墙可变换炫目的灯光色彩。拜仁坐拥超过33座德甲沙拉盘和6座欧冠冠军奖杯，是德甲毫无争议的霸主，在世界范围内拥有超过3亿球迷。', 9.0);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Borussia Dortmund', '多特蒙德', 'Bundesliga', 'Dortmund', 'Germany', 'Signal Iduna Park', TO_DATE('1909-01-01', 'YYYY-MM-DD'), 81212,
'多特蒙德足球俱乐部，成立于1909年，是德国足球的标志性俱乐部。主场为拥有"欧洲第一魔鬼主场"之称的威斯特法伦球场，容量超过81000人，黄色墙壁般的南看场令人震撼。多特蒙德曾5次夺得德甲冠军，1997年赢得欧冠冠军，以青春风暴和高进攻效率著称。', 8.6);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('RB Leipzig', '莱比锡红牛', 'Bundesliga', 'Leipzig', 'Germany', 'Red Bull Arena', TO_DATE('2009-01-01', 'YYYY-MM-DD'), 47069,
'莱比锡红牛足球俱乐部，成立于2009年，是德国足坛近年来崛起的新兴力量。由红牛集团2009年收购后迅速崛起，主场为红牛竞技场。球队从第五级别联赛起步，仅用7年时间便冲入德甲，曾两次夺得德甲亚军，是德国足坛攻势足球的代表。', 8.0);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('VfB Stuttgart', '斯图加特', 'Bundesliga', 'Stuttgart', 'Germany', 'MHPArena', TO_DATE('1893-01-01', 'YYYY-MM-DD'), 60049,
'斯图加特足球俱乐部，成立于1893年，是德国足坛的传统劲旅。主场为MHPArena球场（前称梅赛德斯-奔驰竞技场）。斯图加特是德甲的创始成员之一，曾3次夺得德甲联赛冠军，是巴登-符腾堡州足球的旗帜，球队以坚韧不拔的精神著称。', 7.5);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Eintracht Frankfurt', '法兰克福', 'Bundesliga', 'Frankfurt', 'Germany', 'Deutsche Bank Park', TO_DATE('1899-01-01', 'YYYY-MM-DD'), 58360,
'法兰克福足球俱乐部，成立于1899年，是德甲的创始成员之一。主场为德意志银行公园球场。法兰克福以铁血防守和高强度对抗著称，2022年勇夺欧联杯冠军，是德国足坛作风最顽强的球队之一。', 7.6);

-- 意甲 (Serie A)
INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Inter Milan', '国际米兰', 'Serie A', 'Milan', 'Italy', 'San Siro', TO_DATE('1908-01-01', 'YYYY-MM-DD'), 75923,
'国际米兰足球俱乐部，成立于1908年，是意大利乃至欧洲最具传奇色彩的豪门之一。主场为与AC米兰共用的圣西罗球场。国际米兰是唯一一支从未从意甲降级的球队，3次夺得欧冠冠军，20次问鼎意甲联赛，以"蓝黑军团"之名享誉世界。', 8.6);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('AC Milan', 'AC米兰', 'Serie A', 'Milan', 'Italy', 'San Siro', TO_DATE('1899-01-01', 'YYYY-MM-DD'), 75923,
'AC米兰足球俱乐部，成立于1899年，是世界足坛历史上最成功的俱乐部之一。主场为圣西罗球场。AC米兰曾7次夺得欧冠冠军（仅次于皇马），19次问鼎意甲联赛，以性感足球和顶级青训闻名于世，"红黑军团"的荣耀照耀了整整一个多世纪。', 8.3);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('SSC Napoli', '那不勒斯', 'Serie A', 'Naples', 'Italy', 'Stadio Diego Armando Maradona', TO_DATE('1926-01-01', 'YYYY-MM-DD'), 54726,
'那不勒斯足球俱乐部，成立于1926年，是意大利南部最具代表性的足球俱乐部。主场为以球王马拉多纳命名的迭戈·阿曼多·马拉多纳球场。那不勒斯曾在马拉多纳时代两夺意甲冠军（1986-87, 1989-90），2022-23赛季在斯帕莱蒂带领下再次登顶意甲，是地中海畔的足球明珠。', 8.1);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Juventus', '尤文图斯', 'Serie A', 'Turin', 'Italy', 'Allianz Stadium', TO_DATE('1897-01-01', 'YYYY-MM-DD'), 40619,
'尤文图斯足球俱乐部，成立于1897年，是意大利足坛的"老妇人"和绝对霸主。主场为安联竞技场。尤文图斯36次夺得意甲联赛冠军（历史之最），9次意大利杯冠军，曾2次打进欧冠决赛，以稳健的战术体系和完善的管理著称。', 8.4);

INSERT INTO club (name, short_name, league, city, country, stadium, establish_date, stadium_capacity, description, total_score)
VALUES ('Atalanta', '亚特兰大', 'Serie A', 'Bergamo', 'Italy', 'Gewiss Stadium', TO_DATE('1907-01-01', 'YYYY-MM-DD'), 21300,
'亚特兰大足球俱乐部，成立于1907年，来自意大利北部贝加莫省。主场为Gewiss体育场，是意甲规模最小的球场之一。亚特兰大以超高的进攻效率著称，近年来异军突起，2019年首次闯入欧冠联赛，2020年勇夺欧联杯冠军，书写了小俱乐部的励志传奇。', 8.0);

-- ============================================================
-- 第2部分: 教练数据 (25位主教练)
-- ============================================================

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Mikel Arteta', '米克尔·阿尔特塔', 1, 1, 'Spain', TO_DATE('1982-03-26', 'YYYY-MM-DD'), 8.5, 42);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Pep Guardiola', '佩普·瓜迪奥拉', 2, 1, 'Spain', TO_DATE('1971-01-18', 'YYYY-MM-DD'), 9.3, 87);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Rúben Amorim', '鲁本·阿莫林', 3, 1, 'Portugal', TO_DATE('1990-01-17', 'YYYY-MM-DD'), 8.2, 35);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Enzo Maresca', '恩佐·马雷斯卡', 4, 1, 'Italy', TO_DATE('1980-02-10', 'YYYY-MM-DD'), 8.0, 28);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Arne Slot', '阿恩·斯洛特', 5, 1, 'Netherlands', TO_DATE('1978-09-17', 'YYYY-MM-DD'), 8.7, 51);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Hansi Flick', '汉斯-迪特·弗利克', 6, 1, 'Germany', TO_DATE('1965-02-24', 'YYYY-MM-DD'), 8.4, 39);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Álvaro Arbeloa', '阿尔瓦罗·阿韦洛亚', 7, 1, 'Spain', TO_DATE('1983-01-17', 'YYYY-MM-DD'), 8.1, 22);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Marcelino', '马塞利诺', 8, 1, 'Spain', TO_DATE('1965-08-14', 'YYYY-MM-DD'), 7.8, 31);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Diego Simeone', '迭戈·西蒙尼', 9, 1, 'Argentina', TO_DATE('1970-04-20', 'YYYY-MM-DD'), 8.9, 95);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Imanol Alguacil', '伊马诺尔·阿尔瓜西尔', 10, 1, 'Spain', TO_DATE('1971-06-04', 'YYYY-MM-DD'), 7.7, 29);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Luis Enrique', '路易斯·恩里克', 11, 1, 'Spain', TO_DATE('1970-05-08', 'YYYY-MM-DD'), 8.6, 63);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Pierre Sage', '皮埃尔·萨奇', 12, 1, 'France', TO_DATE('1979-08-16', 'YYYY-MM-DD'), 7.6, 18);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Adi Hütter', '阿迪·许特', 13, 1, 'Austria', TO_DATE('1970-02-29', 'YYYY-MM-DD'), 7.8, 24);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Gennaro Gattuso', '詹纳罗·加图索', 14, 1, 'Italy', TO_DATE('1978-01-09', 'YYYY-MM-DD'), 7.9, 45);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Jorge Sampaoli', '豪尔赫·桑保利', 15, 1, 'Argentina', TO_DATE('1960-03-18', 'YYYY-MM-DD'), 7.5, 33);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Vincent Kompany', '文森特·孔帕尼', 16, 1, 'Belgium', TO_DATE('1986-04-10', 'YYYY-MM-DD'), 8.2, 37);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Niko Kovač', '尼科·科瓦奇', 17, 1, 'Croatia', TO_DATE('1971-10-15', 'YYYY-MM-DD'), 8.0, 56);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Marco Rose', '马尔科·罗泽', 18, 1, 'Germany', TO_DATE('1976-09-11', 'YYYY-MM-DD'), 7.9, 41);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Sebastian Hoeneß', '塞巴斯蒂安·霍内斯', 19, 1, 'Germany', TO_DATE('1981-04-28', 'YYYY-MM-DD'), 7.7, 27);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Dino Toppmöller', '迪诺·托普穆勒', 20, 1, 'Germany', TO_DATE('1980-07-14', 'YYYY-MM-DD'), 7.8, 19);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Christian Chivu', '克里斯蒂安·基伏', 21, 1, 'Romania', TO_DATE('1976-10-18', 'YYYY-MM-DD'), 8.1, 23);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Massimiliano Allegri', '马西米利亚诺·阿莱格里', 22, 1, 'Italy', TO_DATE('1967-08-19', 'YYYY-MM-DD'), 8.3, 78);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Antonio Conte', '安东尼奥·孔蒂', 23, 1, 'Italy', TO_DATE('1969-07-31', 'YYYY-MM-DD'), 8.5, 72);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Thiago Motta', '蒂亚戈·莫塔', 24, 1, 'Brazil', TO_DATE('1982-08-19', 'YYYY-MM-DD'), 8.0, 36);

INSERT INTO coach (name, name_cn, club_id, is_head_coach, nationality, birth_date, avg_score, total_ratings)
VALUES ('Gian Piero Gasperini', '加斯佩里尼', 25, 1, 'Italy', TO_DATE('1958-03-26', 'YYYY-MM-DD'), 8.4, 68);

-- ============================================================
-- 第3部分: 球员数据
-- ============================================================

-- ============ 英超: 阿森纳 (俱乐部ID=1) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('David Raya', '大卫·拉亚', 1, 'GK', 1, 'Spain', TO_DATE('1995-09-15', 'YYYY-MM-DD'), 186, 82, 'ACTIVE', 35000000, 7.9, 23);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('William Saliba', '威廉·萨利巴', 1, 'DF', 2, 'France', TO_DATE('2001-03-24', 'YYYY-MM-DD'), 192, 89, 'ACTIVE', 90000000, 8.8, 54);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Gabriel Magalhães', '加布里埃尔·马加良斯', 1, 'DF', 5, 'Brazil', TO_DATE('1997-12-19', 'YYYY-MM-DD'), 190, 86, 'ACTIVE', 75000000, 8.4, 48);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ben White', '本·怀特', 1, 'DF', 4, 'England', TO_DATE('1997-10-08', 'YYYY-MM-DD'), 182, 75, 'ACTIVE', 55000000, 8.1, 37);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Oleksandr Zinchenko', '津琴科', 1, 'DF', 35, 'Ukraine', TO_DATE('1996-12-15', 'YYYY-MM-DD'), 175, 64, 'ACTIVE', 40000000, 7.9, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Declan Rice', '德克兰·赖斯', 1, 'MF', 41, 'England', TO_DATE('1999-01-14', 'YYYY-MM-DD'), 185, 80, 'ACTIVE', 120000000, 8.7, 66);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Martin Ødegaard', '厄德高', 1, 'MF', 8, 'Norway', TO_DATE('1998-12-17', 'YYYY-MM-DD'), 178, 68, 'ACTIVE', 95000000, 8.6, 58);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Bukayo Saka', '布卡约·萨卡', 1, 'FW', 7, 'England', TO_DATE('2001-09-05', 'YYYY-MM-DD'), 178, 72, 'ACTIVE', 140000000, 8.9, 77);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Gabriel Martinelli', '加布里埃尔·马丁内利', 1, 'FW', 11, 'Brazil', TO_DATE('2001-06-21', 'YYYY-MM-DD'), 180, 73, 'ACTIVE', 85000000, 8.3, 52);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Leandro Trossard', '莱安德罗·特罗萨德', 1, 'FW', 19, 'Belgium', TO_DATE('1994-12-04', 'YYYY-MM-DD'), 174, 73, 'ACTIVE', 45000000, 7.8, 33);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Thomas Partey', '托马斯·帕蒂', 1, 'MF', 5, 'Ghana', TO_DATE('1993-06-13', 'YYYY-MM-DD'), 185, 83, 'ACTIVE', 30000000, 7.5, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Kai Havertz', '凯·哈弗茨', 1, 'FW', 29, 'Germany', TO_DATE('1999-06-11', 'YYYY-MM-DD'), 193, 90, 'ACTIVE', 60000000, 7.7, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Jorginho', '若日尼奥', 1, 'MF', 20, 'Italy', TO_DATE('1991-12-20', 'YYYY-MM-DD'), 180, 68, 'ACTIVE', 18000000, 7.4, 27);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Riccardo Calafiori', '里卡多·卡拉菲奥里', 1, 'DF', 33, 'Italy', TO_DATE('2002-03-10', 'YYYY-MM-DD'), 188, 82, 'ACTIVE', 45000000, 8.2, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mikel Merino', '米克尔·梅里诺', 1, 'MF', 21, 'Spain', TO_DATE('1996-06-22', 'YYYY-MM-DD'), 187, 82, 'ACTIVE', 32000000, 7.8, 25);

-- ============ 英超: 曼城 (俱乐部ID=2) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ederson', '埃德森', 2, 'GK', 31, 'Brazil', TO_DATE('1993-08-17', 'YYYY-MM-DD'), 191, 87, 'ACTIVE', 42000000, 8.4, 51);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Rúben Dias', '鲁本·迪亚斯', 2, 'DF', 3, 'Portugal', TO_DATE('1997-05-14', 'YYYY-MM-DD'), 187, 82, 'ACTIVE', 75000000, 8.6, 62);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Manuel Akanji', '曼努埃尔·阿坎吉', 2, 'DF', 25, 'Switzerland', TO_DATE('1995-07-19', 'YYYY-MM-DD'), 186, 84, 'ACTIVE', 50000000, 8.0, 44);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Josko Gvardiol', '乔斯科·格瓦迪奥尔', 2, 'DF', 24, 'Croatia', TO_DATE('2002-01-20', 'YYYY-MM-DD'), 185, 82, 'ACTIVE', 80000000, 8.5, 39);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Kevin De Bruyne', '凯文·德布劳内', 2, 'MF', 17, 'Belgium', TO_DATE('1991-06-28', 'YYYY-MM-DD'), 181, 70, 'ACTIVE', 55000000, 8.3, 78);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Rodri', '罗德里', 2, 'MF', 16, 'Spain', TO_DATE('1996-06-22', 'YYYY-MM-DD'), 191, 82, 'ACTIVE', 110000000, 9.0, 83);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Bernardo Silva', '贝尔纳多·席尔瓦', 2, 'MF', 20, 'Portugal', TO_DATE('1994-08-10', 'YYYY-MM-DD'), 173, 64, 'ACTIVE', 70000000, 8.4, 67);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Erling Haaland', '埃尔林·哈兰德', 2, 'FW', 9, 'Norway', TO_DATE('2000-07-21', 'YYYY-MM-DD'), 194, 94, 'ACTIVE', 200000000, 9.2, 96);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Phil Foden', '菲尔·福登', 2, 'MF', 47, 'England', TO_DATE('2000-05-28', 'YYYY-MM-DD'), 180, 75, 'ACTIVE', 160000000, 8.8, 72);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Jack Grealish', '杰克·格拉利什', 2, 'FW', 10, 'England', TO_DATE('1995-09-10', 'YYYY-MM-DD'), 180, 76, 'ACTIVE', 55000000, 7.8, 45);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Jeremy Doku', '杰里米·多库', 2, 'FW', 11, 'Ghana', TO_DATE('2002-05-27', 'YYYY-MM-DD'), 176, 68, 'ACTIVE', 60000000, 8.1, 36);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mateo Kovacic', '马特奥·科瓦契奇', 2, 'MF', 8, 'Croatia', TO_DATE('1994-05-06', 'YYYY-MM-DD'), 181, 78, 'ACTIVE', 40000000, 7.7, 32);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Nathan Aké', '内森·阿克', 2, 'DF', 6, 'Netherlands', TO_DATE('1995-01-18', 'YYYY-MM-DD'), 180, 77, 'ACTIVE', 35000000, 7.9, 28);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('John Stones', '约翰·斯通斯', 2, 'DF', 5, 'England', TO_DATE('1994-05-28', 'YYYY-MM-DD'), 188, 85, 'ACTIVE', 30000000, 7.6, 26);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Savinho', '萨维尼奥', 2, 'FW', 26, 'Brazil', TO_DATE('2004-04-10', 'YYYY-MM-DD'), 176, 64, 'ACTIVE', 50000000, 8.0, 21);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('İlkay Gündogan', '京多安', 2, 'MF', 19, 'Germany', TO_DATE('1990-06-24', 'YYYY-MM-DD'), 180, 80, 'ACTIVE', 18000000, 7.5, 48);

-- ============ 英超: 曼联 (俱乐部ID=3) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('André Onana', '安德烈·奥纳纳', 3, 'GK', 24, 'Cameroon', TO_DATE('1996-04-02', 'YYYY-MM-DD'), 190, 90, 'ACTIVE', 40000000, 7.8, 35);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Lisandro Martínez', '利桑德罗·马丁内斯', 3, 'DF', 6, 'Argentina', TO_DATE('1998-01-15', 'YYYY-MM-DD'), 175, 77, 'ACTIVE', 55000000, 8.0, 42);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Raphael Varane', '拉斐尔·瓦拉内', 3, 'DF', 19, 'France', TO_DATE('1993-04-25', 'YYYY-MM-DD'), 191, 85, 'ACTIVE', 25000000, 7.7, 39);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Luke Shaw', '卢克·肖', 3, 'DF', 23, 'England', TO_DATE('1995-07-12', 'YYYY-MM-DD'), 185, 85, 'ACTIVE', 35000000, 7.9, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Bruno Fernandes', '布鲁诺·费尔南德斯', 3, 'MF', 8, 'Portugal', TO_DATE('1994-09-08', 'YYYY-MM-DD'), 179, 69, 'ACTIVE', 75000000, 8.5, 73);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Marcus Rashford', '马库斯·拉什福德', 3, 'FW', 10, 'England', TO_DATE('1997-10-31', 'YYYY-MM-DD'), 185, 70, 'ACTIVE', 50000000, 8.1, 61);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alejandro Garnacho', '亚历杭德罗·加纳乔', 3, 'FW', 17, 'Argentina', TO_DATE('2004-07-01', 'YYYY-MM-DD'), 180, 65, 'ACTIVE', 70000000, 8.3, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mason Mount', '梅森·芒特', 3, 'MF', 7, 'England', TO_DATE('1999-06-10', 'YYYY-MM-DD'), 182, 72, 'ACTIVE', 40000000, 7.6, 34);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Casemiro', '卡塞米罗', 3, 'MF', 18, 'Brazil', TO_DATE('1992-02-23', 'YYYY-MM-DD'), 185, 84, 'ACTIVE', 20000000, 7.5, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Diogo Dalot', '迪奥戈·达洛特', 3, 'DF', 20, 'Portugal', TO_DATE('1999-03-18', 'YYYY-MM-DD'), 184, 76, 'ACTIVE', 35000000, 7.8, 27);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Rasmus Højlund', '拉斯穆斯·霍伊伦', 3, 'FW', 11, 'Denmark', TO_DATE('2003-02-23', 'YYYY-MM-DD'), 191, 88, 'ACTIVE', 65000000, 7.9, 25);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Kobbie Mainoo', '科比·梅诺', 3, 'MF', 37, 'England', TO_DATE('2005-11-13', 'YYYY-MM-DD'), 178, 68, 'ACTIVE', 55000000, 8.2, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Leny Yoro', '莱尼·约罗', 3, 'DF', 15, 'France', TO_DATE('2005-11-13', 'YYYY-MM-DD'), 190, 80, 'ACTIVE', 60000000, 8.1, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Amad Diallo', '阿马德·迪亚洛', 3, 'FW', 16, 'Ivory Coast', TO_DATE('2002-07-11', 'YYYY-MM-DD'), 172, 65, 'ACTIVE', 35000000, 7.7, 18);

-- ============ 英超: 切尔西 (俱乐部ID=4) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Robert Sánchez', '罗伯特·桑切斯', 4, 'GK', 1, 'Spain', TO_DATE('1997-11-18', 'YYYY-MM-DD'), 197, 86, 'ACTIVE', 25000000, 7.5, 21);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Wesley Fofana', '韦斯利·福法纳', 4, 'DF', 3, 'France', TO_DATE('2001-01-14', 'YYYY-MM-DD'), 190, 85, 'ACTIVE', 55000000, 7.9, 26);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Levi Colwill', '列维·科尔维尔', 4, 'DF', 4, 'England', TO_DATE('2003-09-08', 'YYYY-MM-DD'), 186, 82, 'ACTIVE', 45000000, 8.0, 24);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ben Chilwell', '本·奇尔韦尔', 4, 'DF', 21, 'England', TO_DATE('1996-12-28', 'YYYY-MM-DD'), 186, 81, 'ACTIVE', 30000000, 7.6, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Moisés Caicedo', '莫伊塞斯·凯塞多', 4, 'MF', 25, 'Ecuador', TO_DATE('2001-11-02', 'YYYY-MM-DD'), 178, 74, 'ACTIVE', 90000000, 8.3, 35);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Enzo Fernández', '恩佐·费尔南德斯', 4, 'MF', 8, 'Argentina', TO_DATE('2001-01-17', 'YYYY-MM-DD'), 180, 78, 'ACTIVE', 85000000, 8.1, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Cole Palmer', '科尔·帕尔默', 4, 'MF', 20, 'England', TO_DATE('2002-05-09', 'YYYY-MM-DD'), 189, 80, 'ACTIVE', 150000000, 9.0, 68);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Christopher Nkunku', '克里斯托弗·恩昆库', 4, 'FW', 18, 'France', TO_DATE('1997-11-14', 'YYYY-MM-DD'), 175, 72, 'ACTIVE', 65000000, 8.0, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Noni Madueke', '诺尼·马杜埃凯', 4, 'FW', 23, 'England', TO_DATE('2002-03-29', 'YYYY-MM-DD'), 180, 75, 'ACTIVE', 45000000, 7.8, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Pedro Neto', '佩德罗·内托', 4, 'FW', 7, 'Portugal', TO_DATE('2000-03-09', 'YYYY-MM-DD'), 172, 64, 'ACTIVE', 55000000, 8.1, 27);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Romeo Lavia', '罗密欧·拉维亚', 4, 'MF', 45, 'Belgium', TO_DATE('2004-04-29', 'YYYY-MM-DD'), 182, 78, 'ACTIVE', 50000000, 7.7, 18);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Malang Sarr', '马朗·萨尔', 4, 'DF', 92, 'France', TO_DATE('1998-09-10', 'YYYY-MM-DD'), 182, 74, 'ACTIVE', 15000000, 7.3, 17);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Joao Félix', '若昂·菲利克斯', 4, 'FW', 14, 'Portugal', TO_DATE('1999-11-10', 'YYYY-MM-DD'), 180, 70, 'ACTIVE', 40000000, 7.9, 33);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Marc Cucurella', '马克·库库雷拉', 4, 'DF', 3, 'Spain', TO_DATE('1998-07-22', 'YYYY-MM-DD'), 172, 66, 'ACTIVE', 40000000, 7.8, 28);

-- ============ 英超: 利物浦 (俱乐部ID=5) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alisson Becker', '阿利松·贝克尔', 5, 'GK', 1, 'Brazil', TO_DATE('1992-10-02', 'YYYY-MM-DD'), 191, 91, 'ACTIVE', 45000000, 8.7, 64);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Virgil van Dijk', '范戴克', 5, 'DF', 4, 'Netherlands', TO_DATE('1991-07-15', 'YYYY-MM-DD'), 193, 92, 'ACTIVE', 35000000, 8.3, 71);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ibrahima Konaté', '易卜拉希马·科纳特', 5, 'DF', 5, 'France', TO_DATE('1999-05-25', 'YYYY-MM-DD'), 194, 95, 'ACTIVE', 55000000, 8.2, 37);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Trent Alexander-Arnold', '特伦特·亚历山大-阿诺德', 5, 'DF', 66, 'England', TO_DATE('1998-10-07', 'YYYY-MM-DD'), 180, 69, 'ACTIVE', 80000000, 8.6, 59);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Andrew Robertson', '安德鲁·罗伯逊', 5, 'DF', 26, 'Scotland', TO_DATE('1994-03-11', 'YYYY-MM-DD'), 178, 64, 'ACTIVE', 45000000, 8.3, 55);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alexis Mac Allister', '亚历克西斯·麦卡利斯特', 5, 'MF', 10, 'Argentina', TO_DATE('1998-12-24', 'YYYY-MM-DD'), 174, 70, 'ACTIVE', 85000000, 8.4, 44);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Dominik Szoboszlai', '多米尼克·索博斯洛伊', 5, 'MF', 8, 'Hungary', TO_DATE('2000-10-25', 'YYYY-MM-DD'), 186, 75, 'ACTIVE', 70000000, 8.2, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Curtis Jones', '柯蒂斯·琼斯', 5, 'MF', 17, 'England', TO_DATE('2001-01-30', 'YYYY-MM-DD'), 185, 78, 'ACTIVE', 55000000, 8.1, 26);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mohamed Salah', '穆罕默德·萨拉赫', 5, 'FW', 11, 'Egypt', TO_DATE('1992-06-15', 'YYYY-MM-DD'), 175, 71, 'ACTIVE', 55000000, 8.8, 92);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Darwin Núñez', '达尔文·努涅斯', 5, 'FW', 9, 'Uruguay', TO_DATE('1999-06-15', 'YYYY-MM-DD'), 187, 81, 'ACTIVE', 55000000, 8.0, 51);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Luis Díaz', '路易斯·迪亚斯', 5, 'FW', 18, 'Colombia', TO_DATE('1997-01-13', 'YYYY-MM-DD'), 178, 72, 'ACTIVE', 80000000, 8.5, 46);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ryan Gravenberch', '瑞安·赫拉芬贝赫', 5, 'MF', 38, 'Netherlands', TO_DATE('2002-05-16', 'YYYY-MM-DD'), 190, 80, 'ACTIVE', 55000000, 8.1, 25);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Conor Bradley', '康纳·布拉德利', 5, 'DF', 84, 'Northern Ireland', TO_DATE('2003-09-09', 'YYYY-MM-DD'), 178, 68, 'ACTIVE', 35000000, 7.9, 16);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Cody Gakpo', '科迪·加克波', 5, 'FW', 27, 'Netherlands', TO_DATE('1999-05-07', 'YYYY-MM-DD'), 193, 78, 'ACTIVE', 55000000, 8.0, 33);

-- ============ 西甲: 巴塞罗那 (俱乐部ID=6) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Marc-André ter Stegen', '特尔施特根', 6, 'GK', 1, 'Germany', TO_DATE('1992-04-30', 'YYYY-MM-DD'), 187, 85, 'ACTIVE', 40000000, 8.4, 57);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ronald Araújo', '罗纳德·阿劳霍', 6, 'DF', 4, 'Uruguay', TO_DATE('1999-03-07', 'YYYY-MM-DD'), 191, 90, 'ACTIVE', 90000000, 8.7, 46);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Andreas Christensen', '安德烈亚斯·克里斯滕森', 6, 'DF', 15, 'Denmark', TO_DATE('1996-04-10', 'YYYY-MM-DD'), 187, 82, 'ACTIVE', 35000000, 7.8, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Jules Koundé', '朱尔斯·孔德', 6, 'DF', 23, 'France', TO_DATE('1998-11-12', 'YYYY-MM-DD'), 180, 77, 'ACTIVE', 80000000, 8.3, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Pedri', '佩德里', 6, 'MF', 8, 'Spain', TO_DATE('2002-11-25', 'YYYY-MM-DD'), 174, 68, 'ACTIVE', 100000000, 8.6, 54);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Gavi', '加维', 6, 'MF', 6, 'Spain', TO_DATE('2004-08-05', 'YYYY-MM-DD'), 173, 68, 'ACTIVE', 90000000, 8.5, 47);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Frenkie de Jong', '弗兰基·德容', 6, 'MF', 21, 'Netherlands', TO_DATE('1997-05-12', 'YYYY-MM-DD'), 180, 74, 'ACTIVE', 60000000, 8.0, 49);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Robert Lewandowski', '罗伯特·莱万多夫斯基', 6, 'FW', 9, 'Poland', TO_DATE('1988-08-21', 'YYYY-MM-DD'), 185, 81, 'ACTIVE', 25000000, 8.2, 68);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Lamine Yamal', '拉明·亚玛尔', 6, 'FW', 19, 'Spain', TO_DATE('2007-07-13', 'YYYY-MM-DD'), 177, 66, 'ACTIVE', 160000000, 9.0, 58);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Raphinha', '拉菲尼亚', 6, 'FW', 11, 'Brazil', TO_DATE('1996-12-14', 'YYYY-MM-DD'), 178, 73, 'ACTIVE', 60000000, 8.2, 39);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Fermín López', '费尔明·洛佩斯', 6, 'MF', 16, 'Spain', TO_DATE('2003-05-11', 'YYYY-MM-DD'), 179, 73, 'ACTIVE', 50000000, 8.3, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Iñaki Peña', '伊尼亚基·佩尼亚', 6, 'GK', 13, 'Spain', TO_DATE('1999-09-02', 'YYYY-MM-DD'), 184, 76, 'ACTIVE', 25000000, 7.7, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Eric García', '埃里克·加西亚', 6, 'DF', 24, 'Spain', TO_DATE('2001-01-20', 'YYYY-MM-DD'), 185, 76, 'ACTIVE', 20000000, 7.4, 23);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Dani Olmo', '达尼·奥尔莫', 6, 'MF', 20, 'Spain', TO_DATE('1998-05-07', 'YYYY-MM-DD'), 179, 74, 'ACTIVE', 80000000, 8.4, 37);

-- ============ 西甲: 皇家马德里 (俱乐部ID=7) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Thibaut Courtois', '库尔图瓦', 7, 'GK', 1, 'Belgium', TO_DATE('1992-05-11', 'YYYY-MM-DD'), 199, 96, 'ACTIVE', 35000000, 8.5, 62);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Antonio Rüdiger', '安东尼奥·吕迪格', 7, 'DF', 22, 'Germany', TO_DATE('1993-01-03', 'YYYY-MM-DD'), 190, 85, 'ACTIVE', 50000000, 8.2, 48);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Éder Militão', '埃德尔·米利唐', 7, 'DF', 3, 'Brazil', TO_DATE('1998-01-18', 'YYYY-MM-DD'), 186, 79, 'ACTIVE', 70000000, 8.3, 43);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('David Alaba', '大卫·阿拉巴', 7, 'DF', 4, 'Austria', TO_DATE('1992-06-24', 'YYYY-MM-DD'), 180, 78, 'ACTIVE', 25000000, 7.8, 39);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Vinícius Júnior', '维尼修斯·儒尼奥尔', 7, 'FW', 7, 'Brazil', TO_DATE('2000-01-12', 'YYYY-MM-DD'), 176, 73, 'ACTIVE', 200000000, 9.2, 87);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Kylian Mbappé', '基利安·姆巴佩', 7, 'FW', 9, 'France', TO_DATE('1998-12-20', 'YYYY-MM-DD'), 178, 75, 'ACTIVE', 180000000, 9.1, 91);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Rodrygo', '罗德里戈', 7, 'FW', 11, 'Brazil', TO_DATE('2001-09-05', 'YYYY-MM-DD'), 174, 65, 'ACTIVE', 90000000, 8.4, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Jude Bellingham', '裘德·贝林厄姆', 7, 'MF', 5, 'England', TO_DATE('2003-06-29', 'YYYY-MM-DD'), 186, 75, 'ACTIVE', 180000000, 8.9, 63);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Federico Valverde', '费德里科·巴尔韦德', 7, 'MF', 15, 'Uruguay', TO_DATE('1998-07-22', 'YYYY-MM-DD'), 182, 78, 'ACTIVE', 110000000, 8.7, 52);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Eduardo Camavinga', '爱德华多·卡马文加', 7, 'MF', 6, 'France', TO_DATE('2002-11-10', 'YYYY-MM-DD'), 182, 76, 'ACTIVE', 100000000, 8.4, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Luka Modrić', '卢卡·莫德里奇', 7, 'MF', 10, 'Croatia', TO_DATE('1985-09-09', 'YYYY-MM-DD'), 174, 66, 'ACTIVE', 10000000, 7.8, 72);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Dani Carvajal', '丹尼·卡瓦哈尔', 7, 'DF', 2, 'Spain', TO_DATE('1992-01-11', 'YYYY-MM-DD'), 174, 73, 'ACTIVE', 40000000, 8.3, 56);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Raúl Asencio', '劳尔·阿森西奥', 7, 'DF', 35, 'Spain', TO_DATE('2002-12-09', 'YYYY-MM-DD'), 183, 75, 'ACTIVE', 35000000, 8.1, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Brahim Díaz', '布拉希姆·迪亚斯', 7, 'MF', 21, 'Spain', TO_DATE('1999-08-03', 'YYYY-MM-DD'), 180, 68, 'ACTIVE', 35000000, 7.9, 25);

-- ============ 西甲: 比利亚雷亚尔 (俱乐部ID=8) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('José Luis Gayà', '何塞·路易斯·加亚', 8, 'DF', 18, 'Spain', TO_DATE('1995-09-25', 'YYYY-MM-DD'), 180, 73, 'ACTIVE', 40000000, 8.0, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alexander Sørloth', '亚历山大·瑟洛特', 8, 'FW', 9, 'Norway', TO_DATE('1995-12-05', 'YYYY-MM-DD'), 193, 88, 'ACTIVE', 40000000, 8.1, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alex Baena', '亚历克斯·巴埃纳', 8, 'MF', 10, 'Spain', TO_DATE('2001-07-17', 'YYYY-MM-DD'), 176, 67, 'ACTIVE', 50000000, 8.3, 27);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Gerard Moreno', '赫拉德·莫雷诺', 8, 'FW', 7, 'Spain', TO_DATE('1992-04-07', 'YYYY-MM-DD'), 182, 78, 'ACTIVE', 25000000, 7.9, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Juan Foyth', '胡安·福伊特', 8, 'DF', 3, 'Argentina', TO_DATE('1998-01-14', 'YYYY-MM-DD'), 180, 78, 'ACTIVE', 40000000, 7.8, 24);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Yéremy Pino', '耶雷米·皮诺', 8, 'FW', 11, 'Spain', TO_DATE('2002-10-02', 'YYYY-MM-DD'), 174, 66, 'ACTIVE', 50000000, 8.0, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Dani Parejo', '丹尼·帕雷霍', 8, 'MF', 8, 'Spain', TO_DATE('1989-04-16', 'YYYY-MM-DD'), 182, 78, 'ACTIVE', 15000000, 7.6, 46);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Raul Albiol', '劳尔·阿尔比奥尔', 8, 'DF', 2, 'Spain', TO_DATE('1985-09-04', 'YYYY-MM-DD'), 190, 86, 'ACTIVE', 3000000, 7.2, 36);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Aïssa Mandi', '艾萨·曼迪', 8, 'DF', 23, 'Algeria', TO_DATE('1991-10-19', 'YYYY-MM-DD'), 185, 76, 'ACTIVE', 8000000, 7.3, 21);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Manu Trigueros', '马努·特里格罗斯', 8, 'MF', 14, 'Spain', TO_DATE('1991-10-17', 'YYYY-MM-DD'), 179, 75, 'ACTIVE', 12000000, 7.5, 25);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Diego Conde', '迭戈·孔德', 8, 'GK', 1, 'Spain', TO_DATE('1999-03-28', 'YYYY-MM-DD'), 188, 83, 'ACTIVE', 20000000, 7.8, 15);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Etienne Capoue', '埃蒂安·卡普埃', 8, 'MF', 5, 'France', TO_DATE('1988-07-11', 'YYYY-MM-DD'), 185, 84, 'ACTIVE', 10000000, 7.4, 27);

-- ============ 西甲: 马德里竞技 (俱乐部ID=9) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Jan Oblak', '扬·奥布拉克', 9, 'GK', 1, 'Slovenia', TO_DATE('1993-01-07', 'YYYY-MM-DD'), 188, 87, 'ACTIVE', 40000000, 8.5, 63);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('José María Giménez', '何塞·玛丽亚·希门尼斯', 9, 'DF', 2, 'Uruguay', TO_DATE('1995-01-20', 'YYYY-MM-DD'), 185, 76, 'ACTIVE', 40000000, 8.1, 48);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mario Hermoso', '马里奥·埃尔莫索', 9, 'DF', 22, 'Spain', TO_DATE('1995-03-18', 'YYYY-MM-DD'), 184, 79, 'ACTIVE', 30000000, 7.9, 35);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Stefan Savić', '斯特凡·萨维奇', 9, 'DF', 15, 'Montenegro', TO_DATE('1991-01-08', 'YYYY-MM-DD'), 191, 83, 'ACTIVE', 20000000, 7.7, 39);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Rodrigo De Paul', '罗德里戈·德保罗', 9, 'MF', 5, 'Argentina', TO_DATE('1994-05-15', 'YYYY-MM-DD'), 180, 70, 'ACTIVE', 45000000, 8.0, 44);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Koke', '科克', 9, 'MF', 6, 'Spain', TO_DATE('1992-01-08', 'YYYY-MM-DD'), 174, 78, 'ACTIVE', 20000000, 7.8, 58);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Antoine Griezmann', '安托万·格里兹曼', 9, 'FW', 7, 'France', TO_DATE('1991-03-21', 'YYYY-MM-DD'), 176, 73, 'ACTIVE', 25000000, 8.2, 71);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ángel Correa', '安赫尔·科雷亚', 9, 'FW', 10, 'Argentina', TO_DATE('1995-03-09', 'YYYY-MM-DD'), 171, 67, 'ACTIVE', 45000000, 8.1, 49);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Nahuel Molina', '纳韦尔·莫利纳', 9, 'DF', 16, 'Argentina', TO_DATE('1997-12-28', 'YYYY-MM-DD'), 175, 68, 'ACTIVE', 35000000, 7.9, 28);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Pablo Barrios', '帕布洛·巴里奥斯', 9, 'MF', 26, 'Spain', TO_DATE('2003-03-29', 'YYYY-MM-DD'), 181, 74, 'ACTIVE', 30000000, 8.0, 17);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Saúl Ñíguez', '萨乌尔·尼格斯', 9, 'MF', 8, 'Spain', TO_DATE('1994-11-21', 'YYYY-MM-DD'), 178, 76, 'ACTIVE', 15000000, 7.5, 37);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Reinildo', '雷尼尔多', 9, 'DF', 25, 'Mozambique', TO_DATE('1997-08-01', 'YYYY-MM-DD'), 178, 72, 'ACTIVE', 20000000, 7.6, 19);

-- ============ 西甲: 皇家社会 (俱乐部ID=10) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Álex Remiro', '阿莱克斯·雷米罗', 10, 'GK', 1, 'Spain', TO_DATE('1995-05-24', 'YYYY-MM-DD'), 189, 82, 'ACTIVE', 25000000, 8.0, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Robin Le Normand', '罗宾·诺曼德', 10, 'DF', 24, 'France', TO_DATE('1996-04-27', 'YYYY-MM-DD'), 188, 83, 'ACTIVE', 40000000, 8.1, 28);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Nayef Aguerd', '纳伊夫·阿古尔德', 10, 'DF', 5, 'Morocco', TO_DATE('1996-03-30', 'YYYY-MM-DD'), 188, 85, 'ACTIVE', 30000000, 7.8, 23);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Álexander Isak', '亚历山大·伊萨克', 10, 'FW', 9, 'Sweden', TO_DATE('1999-09-21', 'YYYY-MM-DD'), 192, 82, 'ACTIVE', 75000000, 8.6, 37);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mikel Oyarzabal', '米克尔·奥亚萨瓦尔', 10, 'FW', 10, 'Spain', TO_DATE('1997-04-21', 'YYYY-MM-DD'), 180, 70, 'ACTIVE', 55000000, 8.3, 42);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Takefusa Kubo', '久保建英', 10, 'MF', 8, 'Japan', TO_DATE('2001-06-04', 'YYYY-MM-DD'), 173, 68, 'ACTIVE', 60000000, 8.2, 33);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Brais Méndez', '布赖斯·门德斯', 10, 'MF', 14, 'Spain', TO_DATE('1997-01-07', 'YYYY-MM-DD'), 180, 75, 'ACTIVE', 35000000, 8.0, 26);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Martín Zubimendi', '马丁·苏维门迪', 10, 'MF', 4, 'Spain', TO_DATE('1999-02-02', 'YYYY-MM-DD'), 182, 76, 'ACTIVE', 70000000, 8.4, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Álex Sola', '阿莱克斯·索拉', 10, 'DF', 18, 'Spain', TO_DATE('2000-05-02', 'YYYY-MM-DD'), 180, 75, 'ACTIVE', 15000000, 7.7, 15);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Aihen Muñoz', '艾恩·穆尼奥斯', 10, 'DF', 12, 'Spain', TO_DATE('1998-10-16', 'YYYY-MM-DD'), 178, 72, 'ACTIVE', 15000000, 7.7, 17);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Igor Zubeldia', '伊戈尔·苏贝尔迪萨', 10, 'DF', 3, 'Spain', TO_DATE('1997-03-30', 'YYYY-MM-DD'), 186, 80, 'ACTIVE', 25000000, 7.8, 21);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Sheraldo Becker', '谢拉尔多·贝克尔', 10, 'FW', 11, 'Suriname', TO_DATE('1994-02-09', 'YYYY-MM-DD'), 181, 78, 'ACTIVE', 20000000, 7.6, 24);

-- ============ 法甲: 巴黎圣日耳曼 (俱乐部ID=11) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Gianluigi Donnarumma', '多纳鲁马', 11, 'GK', 1, 'Italy', TO_DATE('1999-02-25', 'YYYY-MM-DD'), 196, 90, 'ACTIVE', 55000000, 8.5, 53);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Achraf Hakimi', '阿什拉夫·哈基米', 11, 'DF', 2, 'Morocco', TO_DATE('1998-11-04', 'YYYY-MM-DD'), 181, 73, 'ACTIVE', 75000000, 8.6, 47);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Marquinhos', '马尔基尼奥斯', 11, 'DF', 5, 'Brazil', TO_DATE('1994-05-14', 'YYYY-MM-DD'), 183, 75, 'ACTIVE', 45000000, 8.2, 59);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('William Pacho', '威廉·帕乔', 11, 'DF', 51, 'Ecuador', TO_DATE('2001-10-16', 'YYYY-MM-DD'), 186, 82, 'ACTIVE', 45000000, 8.1, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ousmane Dembélé', '奥斯曼·登贝莱', 11, 'FW', 10, 'France', TO_DATE('1997-05-15', 'YYYY-MM-DD'), 178, 73, 'ACTIVE', 85000000, 8.7, 56);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Khvicha Kvaratskhelia', '克瓦拉茨赫利亚', 11, 'FW', 77, 'Georgia', TO_DATE('2001-02-12', 'YYYY-MM-DD'), 178, 68, 'ACTIVE', 100000000, 8.8, 44);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Bradley Barcola', '布拉德利·巴尔科拉', 11, 'FW', 29, 'France', TO_DATE('2002-09-02', 'YYYY-MM-DD'), 180, 73, 'ACTIVE', 60000000, 8.4, 28);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Gonçalo Ramos', '贡萨洛·拉莫斯', 11, 'FW', 9, 'Portugal', TO_DATE('2001-06-01', 'YYYY-MM-DD'), 185, 76, 'ACTIVE', 55000000, 8.2, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Vitinha', '维蒂尼亚', 11, 'MF', 17, 'Portugal', TO_DATE('2000-04-11', 'YYYY-MM-DD'), 174, 65, 'ACTIVE', 75000000, 8.3, 39);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Warren Zaïre-Emery', '沃伦·扎伊尔-埃默里', 11, 'MF', 33, 'France', TO_DATE('2006-03-08', 'YYYY-MM-DD'), 175, 68, 'ACTIVE', 55000000, 8.2, 21);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Fabian', '法维安', 11, 'MF', 8, 'Spain', TO_DATE('1999-09-15', 'YYYY-MM-DD'), 180, 74, 'ACTIVE', 35000000, 7.9, 25);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Lucas Hernández', '卢卡斯·埃尔南德斯', 11, 'DF', 21, 'France', TO_DATE('1996-02-14', 'YYYY-MM-DD'), 184, 77, 'ACTIVE', 30000000, 7.8, 35);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Lee Kang-in', '李康仁', 11, 'MF', 19, 'South Korea', TO_DATE('2001-02-19', 'YYYY-MM-DD'), 173, 63, 'ACTIVE', 50000000, 8.1, 23);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Matteo Guendouzi', '马特奥·贡多齐', 11, 'MF', 6, 'France', TO_DATE('1999-04-14', 'YYYY-MM-DD'), 183, 74, 'ACTIVE', 35000000, 7.8, 27);

-- ============ 法甲: 里昂 (俱乐部ID=12) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Anthony Lopes', '安东尼·洛佩斯', 12, 'GK', 1, 'Portugal', TO_DATE('1990-05-01', 'YYYY-MM-DD'), 184, 80, 'ACTIVE', 12000000, 7.7, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Maxence Caqueret', '马克桑斯·卡凯雷', 12, 'MF', 6, 'France', TO_DATE('2000-02-28', 'YYYY-MM-DD'), 183, 75, 'ACTIVE', 45000000, 8.2, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Corentin Tolisso', '科朗坦·托利索', 12, 'MF', 8, 'France', TO_DATE('1994-08-03', 'YYYY-MM-DD'), 181, 76, 'ACTIVE', 20000000, 7.6, 35);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alexandre Lacazette', '亚历山大·拉卡泽特', 12, 'FW', 10, 'France', TO_DATE('1991-05-12', 'YYYY-MM-DD'), 175, 73, 'ACTIVE', 20000000, 8.0, 53);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Moussa Dembélé', '穆萨·登贝莱', 12, 'FW', 9, 'France', TO_DATE('1996-07-12', 'YYYY-MM-DD'), 185, 80, 'ACTIVE', 30000000, 7.9, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ryan Cherki', '瑞安·切尔基', 12, 'MF', 7, 'France', TO_DATE('2003-06-03', 'YYYY-MM-DD'), 174, 66, 'ACTIVE', 35000000, 8.1, 21);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Jake O''Brien', '杰克·奥布莱恩', 12, 'DF', 5, 'Ireland', TO_DATE('2001-08-05', 'YYYY-MM-DD'), 193, 88, 'ACTIVE', 25000000, 7.9, 16);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Dejan Lovren', '德扬·洛夫伦', 12, 'DF', 19, 'Croatia', TO_DATE('1989-07-05', 'YYYY-MM-DD'), 190, 84, 'ACTIVE', 8000000, 7.4, 42);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Clément Lenglet', '克莱芒·朗格莱', 12, 'DF', 15, 'France', TO_DATE('1995-04-17', 'YYYY-MM-DD'), 186, 83, 'ACTIVE', 18000000, 7.5, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Malick Ameyaw', '马利克·阿梅亚', 12, 'FW', 21, 'France', TO_DATE('2002-08-15', 'YYYY-MM-DD'), 178, 72, 'ACTIVE', 20000000, 7.7, 12);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Nicolas N''Koulou', '尼古拉斯·恩库洛', 12, 'DF', 12, 'Cameroon', TO_DATE('1990-03-27', 'YYYY-MM-DD'), 183, 80, 'ACTIVE', 5000000, 7.2, 25);

-- ============ 法甲: 摩纳哥 (俱乐部ID=13) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Philipp Köhn', '菲利普·科恩', 13, 'GK', 16, 'Switzerland', TO_DATE('1998-04-06', 'YYYY-MM-DD'), 190, 85, 'ACTIVE', 18000000, 7.6, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Thilo Kehrer', '蒂洛·凯赫尔', 13, 'DF', 25, 'Germany', TO_DATE('1996-09-21', 'YYYY-MM-DD'), 186, 83, 'ACTIVE', 20000000, 7.7, 23);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Axel Disasi', '阿克塞尔·迪萨西', 13, 'DF', 2, 'France', TO_DATE('1998-03-11', 'YYYY-MM-DD'), 190, 86, 'ACTIVE', 40000000, 8.0, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ismail Jakobs', '伊斯梅尔·雅各布斯', 13, 'DF', 14, 'Germany', TO_DATE('1999-08-17', 'YYYY-MM-DD'), 183, 75, 'ACTIVE', 25000000, 7.8, 17);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Youssouf Fofana', '尤苏夫·福法纳', 13, 'MF', 27, 'France', TO_DATE('1999-09-07', 'YYYY-MM-DD'), 184, 76, 'ACTIVE', 45000000, 8.1, 33);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Soungout Camara', '苏恩古特·卡马拉', 13, 'MF', 33, 'France', TO_DATE('2002-09-04', 'YYYY-MM-DD'), 183, 77, 'ACTIVE', 35000000, 8.0, 16);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mohamed Camara', '穆罕默德·卡马拉', 13, 'MF', 6, 'Mali', TO_DATE('2000-02-03', 'YYYY-MM-DD'), 179, 75, 'ACTIVE', 20000000, 7.6, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Breel Embolo', '布雷尔·恩博洛', 13, 'FW', 10, 'Switzerland', TO_DATE('1997-02-14', 'YYYY-MM-DD'), 184, 80, 'ACTIVE', 25000000, 7.8, 28);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Wissam Ben Yedder', '维萨姆·本·耶德', 13, 'FW', 9, 'France', TO_DATE('1990-09-12', 'YYYY-MM-DD'), 170, 62, 'ACTIVE', 25000000, 8.0, 47);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Elisse Ben Seghir', '伊利斯·本·塞吉尔', 13, 'MF', 40, 'France', TO_DATE('2004-11-28', 'YYYY-MM-DD'), 178, 68, 'ACTIVE', 30000000, 7.9, 12);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Caio Henrique', '卡约·恩里克', 13, 'DF', 12, 'Brazil', TO_DATE('1997-12-14', 'YYYY-MM-DD'), 176, 68, 'ACTIVE', 25000000, 7.8, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Vanderson', '万德松', 13, 'DF', 53, 'Brazil', TO_DATE('2001-06-12', 'YYYY-MM-DD'), 183, 75, 'ACTIVE', 30000000, 7.9, 18);

-- ============ 法甲: 马赛 (俱乐部ID=14) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Gianluca Mandi', '詹卢卡·曼丹', 14, 'GK', 16, 'Italy', TO_DATE('1999-07-18', 'YYYY-MM-DD'), 190, 84, 'ACTIVE', 20000000, 7.7, 18);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Leonardo Balerdi', '莱昂纳多·巴莱尔迪', 14, 'DF', 5, 'Argentina', TO_DATE('1999-01-26', 'YYYY-MM-DD'), 185, 82, 'ACTIVE', 30000000, 7.9, 25);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Chancel Mbemba', '钱塞尔·姆本巴', 14, 'DF', 3, 'DR Congo', TO_DATE('1994-08-08', 'YYYY-MM-DD'), 184, 82, 'ACTIVE', 15000000, 7.8, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Jordan Veretout', '若尔丹·韦雷图', 14, 'MF', 6, 'France', TO_DATE('1993-03-01', 'YYYY-MM-DD'), 181, 75, 'ACTIVE', 25000000, 7.8, 33);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('N''Golo Kanté', '恩戈洛·坎特', 14, 'MF', 7, 'France', TO_DATE('1991-03-08', 'YYYY-MM-DD'), 168, 68, 'ACTIVE', 15000000, 7.9, 48);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Valentin Rongier', '瓦朗坦·龙吉埃尔', 14, 'MF', 21, 'France', TO_DATE('1994-12-07', 'YYYY-MM-DD'), 176, 68, 'ACTIVE', 20000000, 7.6, 26);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mason Greenwood', '梅森·格林伍德', 14, 'FW', 10, 'England', TO_DATE('2001-10-01', 'YYYY-MM-DD'), 181, 76, 'ACTIVE', 30000000, 8.1, 28);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Pierre-Emerick Aubameyang', '皮埃尔-埃梅里克·奥巴梅扬', 14, 'FW', 9, 'Gabon', TO_DATE('1989-06-18', 'YYYY-MM-DD'), 185, 80, 'ACTIVE', 15000000, 7.9, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Luis Henrique', '路易斯·恩里克', 14, 'FW', 11, 'Brazil', TO_DATE('2001-12-14', 'YYYY-MM-DD'), 181, 72, 'ACTIVE', 25000000, 7.8, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Jonathan Rowe', '乔纳森·罗', 14, 'FW', 14, 'England', TO_DATE('2003-04-07', 'YYYY-MM-DD'), 178, 72, 'ACTIVE', 35000000, 8.0, 15);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ulisse Garcia', '乌利塞·加西亚', 14, 'DF', 18, 'Switzerland', TO_DATE('1996-08-26', 'YYYY-MM-DD'), 175, 68, 'ACTIVE', 12000000, 7.5, 19);

-- ============ 法甲: 雷恩 (俱乐部ID=15) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Steve Mandanda', '史蒂夫·曼丹达', 15, 'GK', 1, 'DR Congo', TO_DATE('1985-03-10', 'YYYY-MM-DD'), 192, 87, 'ACTIVE', 3000000, 7.4, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Arthur Theate', '亚瑟·特阿特', 15, 'DF', 5, 'Belgium', TO_DATE('2000-05-25', 'YYYY-MM-DD'), 189, 85, 'ACTIVE', 30000000, 7.9, 21);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Christopher Wooh', '克里斯托弗·武奥', 15, 'DF', 4, 'France', TO_DATE('2001-09-18', 'YYYY-MM-DD'), 190, 85, 'ACTIVE', 25000000, 7.8, 16);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Jérémy Doku', '杰雷米·杜库雷', 15, 'FW', 10, 'Ghana', TO_DATE('2002-05-27', 'YYYY-MM-DD'), 176, 68, 'ACTIVE', 40000000, 8.2, 25);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Enzo Le Fée', '恩佐·勒费弗', 15, 'MF', 6, 'France', TO_DATE('2000-05-29', 'YYYY-MM-DD'), 180, 74, 'ACTIVE', 25000000, 7.9, 17);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Boutros Dieng', '布托罗斯·迪昂', 15, 'FW', 9, 'France', TO_DATE('2001-03-21', 'YYYY-MM-DD'), 183, 76, 'ACTIVE', 25000000, 7.8, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alidu Seidu', '阿利杜·塞杜', 15, 'DF', 25, 'Ghana', TO_DATE('2000-06-17', 'YYYY-MM-DD'), 178, 72, 'ACTIVE', 20000000, 7.8, 14);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Azor Matusiwa', '阿佐尔·马图西瓦', 15, 'MF', 27, 'Netherlands', TO_DATE('1998-06-08', 'YYYY-MM-DD'), 185, 78, 'ACTIVE', 15000000, 7.6, 15);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Romain Del Castillo', '罗曼·德尔·卡斯蒂略', 15, 'MF', 10, 'France', TO_DATE('1996-03-29', 'YYYY-MM-DD'), 170, 65, 'ACTIVE', 15000000, 7.5, 19);

-- ============ 德甲: 拜仁慕尼黑 (俱乐部ID=16) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Manuel Neuer', '曼努埃尔·诺伊尔', 16, 'GK', 1, 'Germany', TO_DATE('1986-03-27', 'YYYY-MM-DD'), 193, 92, 'ACTIVE', 15000000, 8.2, 79);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Dayot Upamecano', '达约特·乌帕梅卡诺', 16, 'DF', 2, 'France', TO_DATE('1998-10-27', 'YYYY-MM-DD'), 186, 90, 'ACTIVE', 50000000, 8.0, 42);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Kim Min-jae', '金玟哉', 16, 'DF', 3, 'South Korea', TO_DATE('1996-11-15', 'YYYY-MM-DD'), 190, 86, 'ACTIVE', 65000000, 8.4, 39);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alphonso Davies', '阿方索·戴维斯', 16, 'DF', 19, 'Canada', TO_DATE('2000-06-02', 'YYYY-MM-DD'), 183, 75, 'ACTIVE', 70000000, 8.5, 51);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Joshua Kimmich', '约书亚·基米希', 16, 'MF', 6, 'Germany', TO_DATE('1995-02-08', 'YYYY-MM-DD'), 176, 73, 'ACTIVE', 65000000, 8.6, 68);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Leon Goretzka', '莱昂·格雷茨卡', 16, 'MF', 8, 'Germany', TO_DATE('1995-02-06', 'YYYY-MM-DD'), 190, 82, 'ACTIVE', 50000000, 8.1, 49);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Jamal Musiala', '贾马尔·穆西亚拉', 16, 'MF', 10, 'Germany', TO_DATE('2003-02-26', 'YYYY-MM-DD'), 176, 70, 'ACTIVE', 130000000, 8.9, 55);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Florian Wirtz', '弗洛里安·维尔茨', 16, 'MF', 17, 'Germany', TO_DATE('2003-05-03', 'YYYY-MM-DD'), 176, 68, 'ACTIVE', 140000000, 8.9, 42);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Harry Kane', '哈里·凯恩', 16, 'FW', 9, 'England', TO_DATE('1993-07-28', 'YYYY-MM-DD'), 188, 86, 'ACTIVE', 120000000, 9.0, 66);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Leroy Sané', '勒鲁瓦·萨内', 16, 'FW', 10, 'Germany', TO_DATE('1996-01-11', 'YYYY-MM-DD'), 183, 80, 'ACTIVE', 80000000, 8.4, 52);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Kingsley Coman', '金斯利·科曼', 16, 'FW', 11, 'France', TO_DATE('1996-06-08', 'YYYY-MM-DD'), 178, 74, 'ACTIVE', 65000000, 8.3, 48);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Michael Olise', '迈克尔·奥利塞', 16, 'FW', 42, 'France', TO_DATE('2001-12-12', 'YYYY-MM-DD'), 178, 68, 'ACTIVE', 55000000, 8.3, 23);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Sacha Boey', '萨沙·博埃', 16, 'DF', 20, 'France', TO_DATE('2001-03-13', 'YYYY-MM-DD'), 185, 80, 'ACTIVE', 30000000, 8.0, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Hiroki Ito', '伊藤辉晖', 16, 'DF', 21, 'Japan', TO_DATE('1999-05-12', 'YYYY-MM-DD'), 186, 80, 'ACTIVE', 25000000, 7.8, 14);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Aleksandar Pavlović', '亚历山大·帕夫洛维奇', 16, 'MF', 45, 'Germany', TO_DATE('2003-05-15', 'YYYY-MM-DD'), 185, 79, 'ACTIVE', 30000000, 7.9, 17);

-- ============ 德甲: 多特蒙德 (俱乐部ID=17) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Gregor Kobel', '格雷戈尔·科贝尔', 17, 'GK', 1, 'Switzerland', TO_DATE('1998-04-27', 'YYYY-MM-DD'), 191, 88, 'ACTIVE', 40000000, 8.2, 35);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Niklas Süle', '尼科拉斯·聚勒', 17, 'DF', 25, 'Germany', TO_DATE('1995-09-03', 'YYYY-MM-DD'), 195, 100, 'ACTIVE', 30000000, 7.9, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mats Hummels', '马茨·胡梅尔斯', 17, 'DF', 15, 'Germany', TO_DATE('1988-12-16', 'YYYY-MM-DD'), 191, 92, 'ACTIVE', 15000000, 8.0, 63);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Julian Rypson', '尤利安·赖尔森', 17, 'DF', 13, 'Poland', TO_DATE('1995-08-23', 'YYYY-MM-DD'), 177, 70, 'ACTIVE', 30000000, 7.9, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Julian Brandt', '朱利安·布兰特', 17, 'MF', 10, 'Germany', TO_DATE('1996-05-31', 'YYYY-MM-DD'), 180, 75, 'ACTIVE', 50000000, 8.3, 47);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Marcel Sabitzer', '马塞尔·萨比策', 17, 'MF', 20, 'Austria', TO_DATE('1994-03-17', 'YYYY-MM-DD'), 180, 75, 'ACTIVE', 25000000, 7.8, 32);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Giovanni Reyna', '乔瓦尼·雷纳', 17, 'MF', 7, 'USA', TO_DATE('2002-11-13', 'YYYY-MM-DD'), 185, 76, 'ACTIVE', 35000000, 7.9, 23);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Donyell Malen', '多尼埃尔·马伦', 17, 'FW', 21, 'Netherlands', TO_DATE('1999-07-19', 'YYYY-MM-DD'), 178, 72, 'ACTIVE', 40000000, 8.1, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Karim Adeyemi', '卡里姆·阿德耶米', 17, 'FW', 11, 'Germany', TO_DATE('2002-05-18', 'YYYY-MM-DD'), 180, 73, 'ACTIVE', 35000000, 8.0, 24);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Felix Nmecha', '费利克斯·恩梅加', 17, 'MF', 6, 'Germany', TO_DATE('2000-09-10', 'YYYY-MM-DD'), 188, 79, 'ACTIVE', 35000000, 7.8, 18);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ian Maatsen', '伊恩·马特森', 17, 'DF', 3, 'Netherlands', TO_DATE('2002-03-10', 'YYYY-MM-DD'), 176, 68, 'ACTIVE', 40000000, 8.0, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ramón Pasda', '拉蒙·帕斯达', 17, 'DF', 23, 'Spain', TO_DATE('2002-04-25', 'YYYY-MM-DD'), 184, 78, 'ACTIVE', 25000000, 7.7, 15);

-- ============ 德甲: 莱比锡红牛 (俱乐部ID=18) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Péter Gulácsi', '彼得·古拉奇', 18, 'GK', 1, 'Hungary', TO_DATE('1990-05-06', 'YYYY-MM-DD'), 190, 84, 'ACTIVE', 18000000, 7.9, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Willi Orbán', '威利·奥尔班', 18, 'DF', 4, 'Hungary', TO_DATE('1992-03-03', 'YYYY-MM-DD'), 191, 89, 'ACTIVE', 25000000, 8.1, 43);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('David Raum', '大卫·劳姆', 18, 'DF', 22, 'Germany', TO_DATE('1998-04-22', 'YYYY-MM-DD'), 182, 76, 'ACTIVE', 35000000, 8.0, 33);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Nicolas Seiwald', '尼古拉斯·塞瓦尔', 18, 'MF', 44, 'Austria', TO_DATE('2001-05-08', 'YYYY-MM-DD'), 183, 78, 'ACTIVE', 30000000, 7.9, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Lukas Klostermann', '卢卡斯·克洛斯特曼', 18, 'DF', 16, 'Germany', TO_DATE('1996-06-03', 'YYYY-MM-DD'), 186, 83, 'ACTIVE', 20000000, 7.7, 28);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Lovro Zvonarek', '洛夫罗·兹沃纳雷克', 18, 'MF', 8, 'Croatia', TO_DATE('2004-10-16', 'YYYY-MM-DD'), 182, 76, 'ACTIVE', 25000000, 7.9, 16);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Xavi Simons', '哈维·西蒙斯', 18, 'MF', 20, 'Netherlands', TO_DATE('2003-04-21', 'YYYY-MM-DD'), 175, 68, 'ACTIVE', 60000000, 8.4, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Antonio Nusa', '安东尼奥·努萨', 18, 'FW', 18, 'Norway', TO_DATE('2005-04-29', 'YYYY-MM-DD'), 178, 68, 'ACTIVE', 30000000, 7.9, 12);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Lois Openda', '卢伊斯·奥彭达', 18, 'FW', 11, 'Belgium', TO_DATE('2000-02-16', 'YYYY-MM-DD'), 173, 68, 'ACTIVE', 45000000, 8.2, 27);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Benjamin Šeško', '本杰明·舍什科', 18, 'FW', 9, 'Slovenia', TO_DATE('2003-02-28', 'YYYY-MM-DD'), 195, 83, 'ACTIVE', 50000000, 8.3, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Kevin Kampl', '凯文·坎普尔', 18, 'MF', 44, 'Slovenia', TO_DATE('1990-10-09', 'YYYY-MM-DD'), 178, 70, 'ACTIVE', 15000000, 7.6, 34);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Yussuf Poulsen', '尤素夫·波尔森', 18, 'FW', 9, 'Denmark', TO_DATE('1994-06-15', 'YYYY-MM-DD'), 191, 90, 'ACTIVE', 15000000, 7.7, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('El Chadaille Bitshiabu', '埃尔·查迪尔·比特希亚布', 18, 'DF', 6, 'France', TO_DATE('2005-01-01', 'YYYY-MM-DD'), 195, 85, 'ACTIVE', 15000000, 7.4, 8);

-- ============ 德甲: 斯图加特 (俱乐部ID=19) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alexander Nübel', '亚历山大·努贝尔', 19, 'GK', 1, 'Germany', TO_DATE('1996-09-28', 'YYYY-MM-DD'), 190, 85, 'ACTIVE', 25000000, 7.9, 25);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Waldemar Anton', '瓦尔德马·安东', 19, 'DF', 6, 'Germany', TO_DATE('1996-07-20', 'YYYY-MM-DD'), 189, 85, 'ACTIVE', 35000000, 8.2, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Leander Dendoncker', '勒安德·登东克尔', 19, 'DF', 15, 'Belgium', TO_DATE('1995-04-15', 'YYYY-MM-DD'), 191, 85, 'ACTIVE', 12000000, 7.5, 26);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Maximilian Mittelstädt', '马克西米利安·米特尔施泰特', 19, 'DF', 2, 'Germany', TO_DATE('1997-03-18', 'YYYY-MM-DD'), 178, 68, 'ACTIVE', 30000000, 8.1, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Atakan Karazor', '阿塔坎·卡罗佐尔', 19, 'MF', 3, 'Germany', TO_DATE('1996-06-13', 'YYYY-MM-DD'), 188, 80, 'ACTIVE', 20000000, 7.8, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Angelo Stiller', '安杰洛·斯蒂勒', 19, 'MF', 8, 'Germany', TO_DATE('2000-04-03', 'YYYY-MM-DD'), 180, 73, 'ACTIVE', 20000000, 7.7, 17);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Chris Führich', '克里斯·菲林', 19, 'MF', 42, 'Germany', TO_DATE('1998-03-09', 'YYYY-MM-DD'), 178, 72, 'ACTIVE', 20000000, 7.8, 15);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Deniz Undav', '德尼兹·温达夫', 19, 'FW', 26, 'Germany', TO_DATE('1996-07-01', 'YYYY-MM-DD'), 179, 73, 'ACTIVE', 35000000, 8.1, 26);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ermin Demirovic', '埃尔敏·德米罗维奇', 19, 'FW', 9, 'Bosnia', TO_DATE('1998-11-24', 'YYYY-MM-DD'), 182, 78, 'ACTIVE', 25000000, 7.9, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Nick Woltemade', '尼克·沃尔特马德', 19, 'FW', 19, 'Germany', TO_DATE('2002-03-14', 'YYYY-MM-DD'), 189, 82, 'ACTIVE', 30000000, 7.9, 14);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Levi Müller', '莱维·米勒', 19, 'MF', 7, 'Germany', TO_DATE('2003-05-02', 'YYYY-MM-DD'), 180, 72, 'ACTIVE', 20000000, 7.7, 12);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Fabian Bredlow', '法比安·布雷德洛', 19, 'GK', 33, 'Germany', TO_DATE('1995-03-02', 'YYYY-MM-DD'), 191, 83, 'ACTIVE', 5000000, 7.5, 18);

-- ============ 德甲: 法兰克福 (俱乐部ID=20) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Kevin Trapp', '凯文·特拉普', 20, 'GK', 1, 'Germany', TO_DATE('1990-07-08', 'YYYY-MM-DD'), 188, 83, 'ACTIVE', 18000000, 8.0, 46);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Robin Koch', '罗宾·科赫', 20, 'DF', 25, 'Germany', TO_DATE('1996-07-17', 'YYYY-MM-DD'), 192, 86, 'ACTIVE', 20000000, 7.8, 24);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Philipp Max', '菲利普·马克斯', 20, 'DF', 15, 'Germany', TO_DATE('1993-09-07', 'YYYY-MM-DD'), 177, 70, 'ACTIVE', 15000000, 7.8, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mario Götze', '马里奥·格策', 20, 'MF', 27, 'Germany', TO_DATE('1992-06-03', 'YYYY-MM-DD'), 176, 72, 'ACTIVE', 15000000, 8.0, 48);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Sebastian Rode', '塞巴斯蒂安·罗德', 20, 'MF', 8, 'Germany', TO_DATE('1990-10-04', 'YYYY-MM-DD'), 178, 74, 'ACTIVE', 10000000, 7.6, 35);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Aurèle Amenda', '奥雷尔·阿门达', 20, 'DF', 4, 'Switzerland', TO_DATE('2004-03-01', 'YYYY-MM-DD'), 192, 86, 'ACTIVE', 15000000, 7.7, 10);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Omar Marmoush', '奥马尔·马尔穆什', 20, 'FW', 9, 'Egypt', TO_DATE('1999-02-07', 'YYYY-MM-DD'), 180, 74, 'ACTIVE', 55000000, 8.5, 32);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Hugo Ekitike', '雨果·埃基提克', 20, 'FW', 18, 'France', TO_DATE('2002-06-16', 'YYYY-MM-DD'), 189, 80, 'ACTIVE', 35000000, 8.0, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ansgar Knauff', '安斯加尔·克瑙夫', 20, 'FW', 11, 'Germany', TO_DATE('2002-03-20', 'YYYY-MM-DD'), 183, 74, 'ACTIVE', 15000000, 7.6, 14);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Timothy Chandler', '蒂莫西·钱德勒', 20, 'DF', 6, 'USA', TO_DATE('1990-03-28', 'YYYY-MM-DD'), 186, 82, 'ACTIVE', 5000000, 7.3, 28);

-- ============ 意甲: 国际米兰 (俱乐部ID=21) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Yann Sommer', '扬·索默', 21, 'GK', 1, 'Switzerland', TO_DATE('1988-12-17', 'YYYY-MM-DD'), 183, 78, 'ACTIVE', 15000000, 8.1, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alessandro Bastoni', '亚历山德罗·巴斯托尼', 21, 'DF', 15, 'Italy', TO_DATE('1999-04-19', 'YYYY-MM-DD'), 190, 82, 'ACTIVE', 75000000, 8.5, 39);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Francesco Acerbi', '弗朗切斯科·阿切尔比', 21, 'DF', 31, 'Italy', TO_DATE('1988-02-10', 'YYYY-MM-DD'), 190, 85, 'ACTIVE', 15000000, 8.0, 47);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Nicolò Barella', '尼科洛·巴雷拉', 21, 'MF', 20, 'Italy', TO_DATE('1997-02-07', 'YYYY-MM-DD'), 172, 70, 'ACTIVE', 85000000, 8.6, 54);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Hakan Çalhanoğlu', '哈坎·恰尔汗奥卢', 21, 'MF', 20, 'Turkey', TO_DATE('1994-02-08', 'YYYY-MM-DD'), 178, 75, 'ACTIVE', 50000000, 8.3, 49);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Marcelo Brozović', '马塞洛·布罗佐维奇', 21, 'MF', 77, 'Croatia', TO_DATE('1992-11-16', 'YYYY-MM-DD'), 180, 78, 'ACTIVE', 35000000, 8.1, 51);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Lautaro Martínez', '劳塔罗·马丁内斯', 21, 'FW', 9, 'Argentina', TO_DATE('1997-08-10', 'YYYY-MM-DD'), 174, 72, 'ACTIVE', 110000000, 8.8, 63);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Marcus Thuram', '马库斯·图拉姆', 21, 'FW', 9, 'France', TO_DATE('1997-08-26', 'YYYY-MM-DD'), 192, 86, 'ACTIVE', 65000000, 8.4, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mehdi Taremi', '迈赫迪·塔雷米', 21, 'FW', 99, 'Iran', TO_DATE('1992-07-18', 'YYYY-MM-DD'), 186, 82, 'ACTIVE', 25000000, 8.1, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Federico Dimarco', '费德里科·迪马尔科', 21, 'DF', 32, 'Italy', TO_DATE('1997-11-10', 'YYYY-MM-DD'), 175, 68, 'ACTIVE', 55000000, 8.4, 36);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Denzel Dumfries', '丹泽尔·邓弗里斯', 21, 'DF', 2, 'Netherlands', TO_DATE('1996-04-18', 'YYYY-MM-DD'), 188, 78, 'ACTIVE', 40000000, 8.0, 33);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Carlos Augusto', '卡洛斯·奥古斯托', 21, 'DF', 30, 'Brazil', TO_DATE('1999-01-05', 'YYYY-MM-DD'), 185, 78, 'ACTIVE', 30000000, 7.9, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Davide Frattesi', '戴维德·弗拉泰西', 21, 'MF', 16, 'Italy', TO_DATE('1999-09-22', 'YYYY-MM-DD'), 180, 74, 'ACTIVE', 45000000, 8.2, 28);

-- ============ 意甲: AC米兰 (俱乐部ID=22) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mike Maignan', '迈克·迈尼昂', 22, 'GK', 16, 'France', TO_DATE('1995-07-03', 'YYYY-MM-DD'), 191, 85, 'ACTIVE', 45000000, 8.4, 42);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Fikayo Tomori', '菲卡约·托莫里', 22, 'DF', 23, 'England', TO_DATE('1997-12-19', 'YYYY-MM-DD'), 185, 85, 'ACTIVE', 45000000, 8.2, 36);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Malick Thiaw', '马利克·蒂亚乌', 22, 'DF', 28, 'Germany', TO_DATE('2001-08-08', 'YYYY-MM-DD'), 194, 90, 'ACTIVE', 50000000, 8.1, 25);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Theo Hernandez', '特奥·埃尔南德斯', 22, 'DF', 19, 'France', TO_DATE('1997-10-06', 'YYYY-MM-DD'), 184, 78, 'ACTIVE', 90000000, 8.8, 52);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Tommaso Pobega', '托马索·波贝加', 22, 'MF', 32, 'Italy', TO_DATE('1999-07-15', 'YYYY-MM-DD'), 186, 80, 'ACTIVE', 25000000, 7.9, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Christian Pulisic', '克里斯蒂安·普利西奇', 22, 'MF', 11, 'USA', TO_DATE('1998-09-18', 'YYYY-MM-DD'), 180, 70, 'ACTIVE', 45000000, 8.2, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Rafael Leão', '拉斐尔·莱奥', 22, 'FW', 10, 'Portugal', TO_DATE('1999-06-10', 'YYYY-MM-DD'), 188, 81, 'ACTIVE', 90000000, 8.6, 47);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Noah Okafor', '诺亚·奥卡福', 22, 'FW', 14, 'Switzerland', TO_DATE('2000-05-10', 'YYYY-MM-DD'), 185, 80, 'ACTIVE', 30000000, 8.0, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Álvaro Morata', '阿尔瓦罗·莫拉塔', 22, 'FW', 7, 'Spain', TO_DATE('1992-10-10', 'YYYY-MM-DD'), 187, 82, 'ACTIVE', 25000000, 8.0, 44);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Davide Calabria', '戴维德·卡拉布里亚', 22, 'DF', 2, 'Italy', TO_DATE('1996-12-06', 'YYYY-MM-DD'), 179, 72, 'ACTIVE', 25000000, 7.9, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Sandro Tonali', '桑德罗·托纳利', 22, 'MF', 8, 'Italy', TO_DATE('2000-05-08', 'YYYY-MM-DD'), 181, 78, 'ACTIVE', 55000000, 8.1, 29);

-- ============ 意甲: 那不勒斯 (俱乐部ID=23) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alex Meret', '亚历克斯·梅雷特', 23, 'GK', 1, 'Italy', TO_DATE('1997-05-22', 'YYYY-MM-DD'), 190, 85, 'ACTIVE', 30000000, 8.0, 33);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Alessandro Buongiorno', '亚历山德罗·布翁乔尔诺', 23, 'DF', 5, 'Italy', TO_DATE('1999-03-06', 'YYYY-MM-DD'), 190, 85, 'ACTIVE', 45000000, 8.2, 24);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mathias Olivera', '马蒂亚斯·奥利维拉', 23, 'DF', 17, 'Uruguay', TO_DATE('1998-04-27', 'YYYY-MM-DD'), 184, 80, 'ACTIVE', 30000000, 7.9, 21);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Giovanni Di Lorenzo', '乔瓦尼·迪洛伦佐', 23, 'DF', 22, 'Italy', TO_DATE('1993-07-04', 'YYYY-MM-DD'), 182, 74, 'ACTIVE', 30000000, 8.0, 38);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Frank Zambo Anguissa', '弗兰克·赞博·安古伊萨', 23, 'MF', 99, 'Cameroon', TO_DATE('2000-11-16', 'YYYY-MM-DD'), 184, 78, 'ACTIVE', 50000000, 8.3, 35);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Stanislav Lobotka', '斯坦尼斯洛夫·洛博特卡', 23, 'MF', 68, 'Slovakia', TO_DATE('1994-07-25', 'YYYY-MM-DD'), 170, 66, 'ACTIVE', 55000000, 8.4, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Matteo Politano', '马泰奥·波利塔诺', 23, 'FW', 11, 'Italy', TO_DATE('1993-08-03', 'YYYY-MM-DD'), 171, 70, 'ACTIVE', 25000000, 8.0, 29);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Romelu Lukaku', '罗梅卢·卢卡库', 23, 'FW', 9, 'Belgium', TO_DATE('1993-05-06', 'YYYY-MM-DD'), 191, 101, 'ACTIVE', 35000000, 8.2, 58);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('David Neres', '大卫·内雷斯', 23, 'FW', 11, 'Brazil', TO_DATE('1997-03-03', 'YYYY-MM-DD'), 176, 68, 'ACTIVE', 35000000, 8.0, 28);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Leonardo Spinazzola', '莱昂纳多·斯皮纳佐拉', 23, 'DF', 3, 'Italy', TO_DATE('1992-06-25', 'YYYY-MM-DD'), 186, 78, 'ACTIVE', 20000000, 7.8, 32);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Giacomo Raspadori', '贾科莫·拉斯帕多里', 23, 'FW', 81, 'Italy', TO_DATE('2000-02-18', 'YYYY-MM-DD'), 182, 72, 'ACTIVE', 40000000, 8.1, 29);

-- ============ 意甲: 尤文图斯 (俱乐部ID=24) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Wojciech Szczesny', '沃伊切赫·什琴斯尼', 24, 'GK', 1, 'Poland', TO_DATE('1990-04-18', 'YYYY-MM-DD'), 196, 90, 'ACTIVE', 15000000, 7.9, 48);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Gleison Bremer', '格雷松·布雷默', 24, 'DF', 3, 'Brazil', TO_DATE('1997-03-18', 'YYYY-MM-DD'), 185, 82, 'ACTIVE', 65000000, 8.5, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Pierre Kalulu', '皮埃尔·卡卢卢', 24, 'DF', 15, 'France', TO_DATE('2000-07-05', 'YYYY-MM-DD'), 184, 78, 'ACTIVE', 40000000, 8.0, 27);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Manuel Locatelli', '曼努埃尔·洛卡特利', 24, 'MF', 5, 'Italy', TO_DATE('1998-01-12', 'YYYY-MM-DD'), 182, 75, 'ACTIVE', 50000000, 8.2, 39);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Nicolò Fagioli', '尼科洛·法乔利', 24, 'MF', 8, 'Italy', TO_DATE('2001-02-10', 'YYYY-MM-DD'), 180, 74, 'ACTIVE', 40000000, 8.0, 23);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Kenan Yildiz', '凯南·伊尔迪兹', 24, 'MF', 15, 'Turkey', TO_DATE('2005-05-29', 'YYYY-MM-DD'), 183, 73, 'ACTIVE', 50000000, 8.3, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Dusan Vlahovic', '杜桑·弗拉霍维奇', 24, 'FW', 9, 'Serbia', TO_DATE('2000-01-28', 'YYYY-MM-DD'), 190, 86, 'ACTIVE', 60000000, 8.2, 44);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Federico Chiesa', '费德里科·基耶萨', 24, 'FW', 7, 'Italy', TO_DATE('1997-10-25', 'YYYY-MM-DD'), 175, 70, 'ACTIVE', 50000000, 8.3, 41);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Arkadiusz Milik', '阿尔卡迪乌什·米利克', 24, 'FW', 14, 'Poland', TO_DATE('1994-02-28', 'YYYY-MM-DD'), 190, 84, 'ACTIVE', 20000000, 7.8, 35);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Timothy Weah', '蒂莫西·维阿', 24, 'FW', 18, 'USA', TO_DATE('2003-02-17', 'YYYY-MM-DD'), 183, 76, 'ACTIVE', 25000000, 7.9, 18);

-- ============ 意甲: 亚特兰大 (俱乐部ID=25) ============
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Marco Carnesecchi', '马尔科·卡尔内塞基', 25, 'GK', 29, 'Italy', TO_DATE('2000-07-01', 'YYYY-MM-DD'), 190, 84, 'ACTIVE', 35000000, 8.1, 22);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Isak Hien', '伊萨克·希恩', 25, 'DF', 4, 'Sweden', TO_DATE('1999-03-31', 'YYYY-MM-DD'), 190, 83, 'ACTIVE', 35000000, 8.2, 19);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Berat Djimsiti', '贝拉特·吉姆西蒂', 25, 'DF', 15, 'Albania', TO_DATE('1992-09-19', 'YYYY-MM-DD'), 190, 84, 'ACTIVE', 20000000, 7.9, 33);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ederson Santana', '埃德森·桑塔纳', 25, 'MF', 13, 'Brazil', TO_DATE('1997-07-24', 'YYYY-MM-DD'), 179, 68, 'ACTIVE', 45000000, 8.4, 31);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Marten de Roon', '马尔滕·德鲁恩', 25, 'MF', 15, 'Netherlands', TO_DATE('1991-03-29', 'YYYY-MM-DD'), 180, 78, 'ACTIVE', 20000000, 7.8, 36);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Mario Pašalic', '马里奥·帕萨利奇', 25, 'MF', 8, 'Croatia', TO_DATE('1995-07-09', 'YYYY-MM-DD'), 186, 78, 'ACTIVE', 30000000, 8.0, 34);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Ademola Lookman', '阿德莫拉·卢克曼', 25, 'FW', 11, 'Nigeria', TO_DATE('1997-10-20', 'YYYY-MM-DD'), 175, 70, 'ACTIVE', 55000000, 8.5, 32);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Matteo Retegui', '马泰奥·雷泰圭', 25, 'FW', 91, 'Italy', TO_DATE('1999-10-29', 'YYYY-MM-DD'), 186, 82, 'ACTIVE', 40000000, 8.3, 21);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Lazar Samardzic', '拉扎尔·萨马尔季奇', 25, 'MF', 18, 'Serbia', TO_DATE('2002-02-24', 'YYYY-MM-DD'), 181, 72, 'ACTIVE', 35000000, 8.1, 18);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Gianluca Scamacca', '詹卢卡·斯卡马卡', 25, 'FW', 90, 'Italy', TO_DATE('1999-01-09', 'YYYY-MM-DD'), 195, 91, 'ACTIVE', 30000000, 8.0, 26);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Davide Zappacosta', '戴维德·扎帕科斯塔', 25, 'DF', 3, 'Italy', TO_DATE('1992-06-12', 'YYYY-MM-DD'), 180, 75, 'ACTIVE', 8000000, 7.5, 24);
INSERT INTO player (name, name_cn, club_id, position, jersey_number, nationality, birth_date, height_cm, weight_kg, status, market_value, avg_score, total_ratings)
VALUES ('Sead Kolasinac', '塞亚德·科拉希纳克', 25, 'DF', 23, 'Bosnia', TO_DATE('1993-05-20', 'YYYY-MM-DD'), 184, 85, 'ACTIVE', 10000000, 7.6, 26);

-- ============================================================
-- 第4部分: 比赛数据
-- ============================================================

-- 英超
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL001', 2, 1, TO_TIMESTAMP('2026-04-05 19:30:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2, 'FINISHED', '第32轮', '伊蒂哈德球场', 'Michael Oliver', 'Premier League', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL002', 5, 3, TO_TIMESTAMP('2026-04-08 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 1, 'FINISHED', '第32轮', '安菲尔德球场', 'Anthony Taylor', 'Premier League', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL003', 4, 2, TO_TIMESTAMP('2026-04-12 19:30:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 3, 'FINISHED', '第33轮', '斯坦福桥球场', 'Simon Hooper', 'Premier League', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL004', 1, 5, TO_TIMESTAMP('2026-04-15 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 1, 'FINISHED', '第33轮', '酋长球场', 'Paul Tierney', 'Premier League', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL005', 3, 4, TO_TIMESTAMP('2026-04-18 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2, 'FINISHED', '第34轮', '老特拉福德球场', 'Chris Kavanagh', 'Premier League', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL006', 2, 5, TO_TIMESTAMP('2026-04-21 23:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2, 'IN_PROGRESS', '第34轮', '伊蒂哈德球场', 'Michael Oliver', 'Premier League', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL007', 1, 3, TO_TIMESTAMP('2026-04-25 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, NULL, 'PENDING', '第35轮', '酋长球场', 'TBD', 'Premier League', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL008', 4, 1, TO_TIMESTAMP('2026-04-28 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, NULL, 'PENDING', '第35轮', '斯坦福桥球场', 'TBD', 'Premier League', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL009', 3, 2, TO_TIMESTAMP('2026-05-02 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, NULL, 'PENDING', '第36轮', '老特拉福德球场', 'TBD', 'Premier League', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL010', 5, 4, TO_TIMESTAMP('2026-05-05 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, NULL, 'PENDING', '第36轮', '安菲尔德球场', 'TBD', 'Premier League', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL011', 1, 4, TO_TIMESTAMP('2026-03-15 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 0, 'FINISHED', '第30轮', '酋长球场', 'Simon Hooper', 'Premier League', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('EPL012', 2, 3, TO_TIMESTAMP('2026-03-22 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 1, 'FINISHED', '第30轮', '伊蒂哈德球场', 'Anthony Taylor', 'Premier League', '2025-2026');

-- 西甲
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LAL001', 7, 6, TO_TIMESTAMP('2026-04-06 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 1, 'FINISHED', '第30轮', '伯纳乌球场', 'Mateu Lahoz', 'La Liga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LAL002', 9, 10, TO_TIMESTAMP('2026-04-09 03:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 0, 'FINISHED', '第31轮', '大都会球场', 'Cuartero', 'La Liga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LAL003', 6, 8, TO_TIMESTAMP('2026-04-13 03:00:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 2, 'FINISHED', '第31轮', '诺坎普球场', 'Soto', 'La Liga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LAL004', 7, 9, TO_TIMESTAMP('2026-04-16 03:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2, 'FINISHED', '第32轮', '伯纳乌球场', 'Gil Manzano', 'La Liga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LAL005', 6, 10, TO_TIMESTAMP('2026-04-19 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 0, 'FINISHED', '第32轮', '诺坎普球场', 'Hernández', 'La Liga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LAL006', 8, 9, TO_TIMESTAMP('2026-04-22 03:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 1, 'IN_PROGRESS', '第33轮', '陶瓷球场', 'Melero', 'La Liga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LAL007', 10, 7, TO_TIMESTAMP('2026-04-25 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, NULL, 'PENDING', '第33轮', 'Anoeta球场', 'TBD', 'La Liga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LAL008', 6, 7, TO_TIMESTAMP('2026-05-03 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, NULL, 'PENDING', '第34轮', '诺坎普球场', 'TBD', 'La Liga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LAL009', 9, 6, TO_TIMESTAMP('2026-03-16 03:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 2, 'FINISHED', '第29轮', '大都会球场', 'Soto', 'La Liga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LAL010', 10, 8, TO_TIMESTAMP('2026-03-23 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 1, 'FINISHED', '第30轮', 'Anoeta球场', 'Cuartero', 'La Liga', '2025-2026');

-- 法甲
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LIG001', 11, 12, TO_TIMESTAMP('2026-04-05 23:05:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 1, 'FINISHED', '第29轮', '王子公园球场', 'F. Letexier', 'Ligue 1', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LIG002', 13, 14, TO_TIMESTAMP('2026-04-08 03:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 2, 'FINISHED', '第30轮', '路易二世体育场', 'B. Millot', 'Ligue 1', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LIG003', 14, 15, TO_TIMESTAMP('2026-04-12 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 1, 'FINISHED', '第30轮', '韦洛德罗姆球场', 'R. Buquet', 'Ligue 1', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LIG004', 11, 13, TO_TIMESTAMP('2026-04-15 03:00:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 0, 'FINISHED', '第31轮', '王子公园球场', 'W. Delaporge', 'Ligue 1', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LIG005', 12, 14, TO_TIMESTAMP('2026-04-19 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 3, 'FINISHED', '第31轮', 'Groupama体育场', 'F. Letexier', 'Ligue 1', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LIG006', 15, 11, TO_TIMESTAMP('2026-04-22 03:00:00', 'YYYY-MM-DD HH24:MI:SS'), 0, 2, 'IN_PROGRESS', '第32轮', 'Roazhon公园', 'B. Millot', 'Ligue 1', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LIG007', 13, 12, TO_TIMESTAMP('2026-04-25 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, NULL, 'PENDING', '第32轮', '路易二世体育场', 'TBD', 'Ligue 1', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('LIG008', 11, 14, TO_TIMESTAMP('2026-03-15 23:05:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 2, 'FINISHED', '第28轮', '王子公园球场', 'C. Thual', 'Ligue 1', '2025-2026');

-- 德甲
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('BUN001', 16, 17, TO_TIMESTAMP('2026-04-04 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 1, 'FINISHED', '第29轮', '安联竞技场', 'F. Brych', 'Bundesliga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('BUN002', 18, 19, TO_TIMESTAMP('2026-04-07 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2, 'FINISHED', '第29轮', '红牛竞技场', 'S. Stegemann', 'Bundesliga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('BUN003', 17, 20, TO_TIMESTAMP('2026-04-11 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 0, 'FINISHED', '第30轮', '威斯特法伦球场', 'M. Jüller', 'Bundesliga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('BUN004', 16, 18, TO_TIMESTAMP('2026-04-14 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 1, 'FINISHED', '第30轮', '安联竞技场', 'H. Osmers', 'Bundesliga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('BUN005', 19, 16, TO_TIMESTAMP('2026-04-18 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 3, 'FINISHED', '第31轮', 'MHPArena', 'F. Zwayer', 'Bundesliga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('BUN006', 20, 17, TO_TIMESTAMP('2026-04-21 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 1, 'IN_PROGRESS', '第31轮', '德意志银行公园', 'D. Schlager', 'Bundesliga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('BUN007', 16, 19, TO_TIMESTAMP('2026-04-25 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, NULL, 'PENDING', '第32轮', '安联竞技场', 'TBD', 'Bundesliga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('BUN008', 17, 18, TO_TIMESTAMP('2026-05-03 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, NULL, 'PENDING', '第32轮', '威斯特法伦球场', 'TBD', 'Bundesliga', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('BUN009', 16, 20, TO_TIMESTAMP('2026-03-15 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 0, 'FINISHED', '第27轮', '安联竞技场', 'F. Brych', 'Bundesliga', '2025-2026');

-- 意甲
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('SER001', 21, 22, TO_TIMESTAMP('2026-04-05 21:45:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 1, 'FINISHED', '第31轮', '圣西罗球场', 'M. Mariani', 'Serie A', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('SER002', 24, 23, TO_TIMESTAMP('2026-04-08 02:45:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 1, 'FINISHED', '第31轮', '安联竞技场', 'F. Maresca', 'Serie A', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('SER003', 25, 21, TO_TIMESTAMP('2026-04-11 02:45:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 3, 'FINISHED', '第32轮', '蓝色运动员球场', 'S. Sozza', 'Serie A', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('SER004', 22, 24, TO_TIMESTAMP('2026-04-14 02:45:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 0, 'FINISHED', '第32轮', '圣西罗球场', 'M. Rapta', 'Serie A', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('SER005', 23, 25, TO_TIMESTAMP('2026-04-17 02:45:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 1, 'FINISHED', '第33轮', '马拉多纳球场', 'L. Abisso', 'Serie A', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('SER006', 21, 23, TO_TIMESTAMP('2026-04-20 21:45:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 1, 'IN_PROGRESS', '第33轮', '圣西罗球场', 'M. Mariani', 'Serie A', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('SER007', 24, 25, TO_TIMESTAMP('2026-04-24 02:45:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, NULL, 'PENDING', '第34轮', '安联竞技场', 'TBD', 'Serie A', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('SER008', 22, 21, TO_TIMESTAMP('2026-05-01 02:45:00', 'YYYY-MM-DD HH24:MI:SS'), NULL, NULL, 'PENDING', '第34轮', '圣西罗球场', 'TBD', 'Serie A', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('SER009', 23, 24, TO_TIMESTAMP('2026-03-16 21:45:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 2, 'FINISHED', '第30轮', '马拉多纳球场', 'F. Maresca', 'Serie A', '2025-2026');
INSERT INTO match_schedule (match_id, home_club_id, away_club_id, match_time, home_score, away_score, status, round, venue, referee, league, season)
VALUES ('SER010', 21, 24, TO_TIMESTAMP('2026-03-23 21:45:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 1, 'FINISHED', '第30轮', '圣西罗球场', 'M. Mariani', 'Serie A', '2025-2026');

-- ============================================================
-- 第5部分: 积分榜数据 (2025-2026赛季)
-- ============================================================

-- 英超
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Premier League', '2025-2026', 2, 1, 34, 26, 6, 2, 78, 25, 53, 84);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Premier League', '2025-2026', 5, 2, 34, 24, 7, 3, 72, 28, 44, 79);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Premier League', '2025-2026', 1, 3, 34, 22, 8, 4, 68, 32, 36, 74);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Premier League', '2025-2026', 4, 4, 34, 18, 10, 6, 58, 38, 20, 64);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Premier League', '2025-2026', 3, 5, 34, 16, 9, 9, 48, 42, 6, 57);

-- 西甲
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('La Liga', '2025-2026', 7, 1, 32, 24, 5, 3, 72, 24, 48, 77);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('La Liga', '2025-2026', 6, 2, 32, 22, 6, 4, 68, 30, 38, 72);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('La Liga', '2025-2026', 9, 3, 32, 19, 8, 5, 52, 28, 24, 65);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('La Liga', '2025-2026', 10, 4, 32, 16, 10, 6, 48, 32, 16, 58);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('La Liga', '2025-2026', 8, 5, 32, 14, 9, 9, 45, 38, 7, 51);

-- 法甲
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Ligue 1', '2025-2026', 11, 1, 32, 25, 5, 2, 82, 18, 64, 80);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Ligue 1', '2025-2026', 14, 2, 32, 18, 8, 6, 52, 32, 20, 62);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Ligue 1', '2025-2026', 13, 3, 32, 17, 9, 6, 55, 38, 17, 60);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Ligue 1', '2025-2026', 12, 4, 32, 16, 8, 8, 48, 35, 13, 56);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Ligue 1', '2025-2026', 15, 5, 32, 14, 10, 8, 42, 36, 6, 52);

-- 德甲
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Bundesliga', '2025-2026', 16, 1, 31, 23, 5, 3, 78, 22, 56, 74);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Bundesliga', '2025-2026', 18, 2, 31, 19, 7, 5, 62, 32, 30, 64);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Bundesliga', '2025-2026', 17, 3, 31, 18, 8, 5, 58, 35, 23, 62);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Bundesliga', '2025-2026', 20, 4, 31, 15, 9, 7, 52, 38, 14, 54);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Bundesliga', '2025-2026', 19, 5, 31, 14, 8, 9, 48, 42, 6, 50);

-- 意甲
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Serie A', '2025-2026', 21, 1, 33, 23, 6, 4, 65, 25, 40, 75);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Serie A', '2025-2026', 23, 2, 33, 21, 8, 4, 58, 28, 30, 71);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Serie A', '2025-2026', 22, 3, 33, 20, 7, 6, 55, 32, 23, 67);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Serie A', '2025-2026', 24, 4, 33, 19, 9, 5, 52, 30, 22, 66);
INSERT INTO league_standings (league, season, club_id, position, played, won, drawn, lost, goals_for, goals_against, goal_diff, points)
VALUES ('Serie A', '2025-2026', 25, 5, 33, 18, 8, 7, 58, 38, 20, 62);

-- ============================================================
-- 第6部分: 字典数据
-- ============================================================

INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('LEAGUE', 'Premier League', '英格兰足球超级联赛', 1, 1, '英格兰顶级足球联赛');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('LEAGUE', 'La Liga', '西班牙足球甲级联赛', 2, 1, '西班牙顶级足球联赛');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('LEAGUE', 'Ligue 1', '法国足球甲级联赛', 3, 1, '法国顶级足球联赛');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('LEAGUE', 'Bundesliga', '德国足球甲级联赛', 4, 1, '德国顶级足球联赛');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('LEAGUE', 'Serie A', '意大利足球甲级联赛', 5, 1, '意大利顶级足球联赛');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('SEASON', '2025-2026', '2025-2026赛季', 1, 1, '当前赛季');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('POSITION', 'GK', '守门员', 1, 1, '守门员位置');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('POSITION', 'DF', '后卫', 2, 1, '后卫位置');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('POSITION', 'MF', '中场', 3, 1, '中场位置');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('POSITION', 'FW', '前锋', 4, 1, '前锋位置');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('PLAYER_STATUS', 'ACTIVE', '活跃', 1, 1, '球员活跃状态');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('PLAYER_STATUS', 'INJURED', '受伤', 2, 1, '球员受伤状态');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('PLAYER_STATUS', 'RETIRED', '退役', 3, 1, '球员退役状态');
INSERT INTO system_dictionary (dict_type, dict_key, dict_value, sort_order, is_enabled, description)
VALUES ('PLAYER_STATUS', 'FREE', '自由身', 4, 1, '球员自由身状态');

COMMIT;
