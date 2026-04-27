<template>
  <div class="page-container">
    <div class="page-header">
      <h1>超级管理后台</h1>
    </div>

    <div class="admin-tabs">
      <el-tabs v-model="activeTab" type="border-card">
        <el-tab-pane label="分析统计" name="stats">
          <div v-if="analytics" class="analytics-section">
            <h3 style="margin:0 0 14px;font-size:16px;color:var(--color-text-primary)">总览</h3>
            <div class="stats-grid">
              <div class="stat-card">
                <span class="stat-value">{{ analytics.overview?.totalUsers ?? 0 }}</span>
                <span class="stat-label">总用户数</span>
              </div>
              <div class="stat-card">
                <span class="stat-value">{{ analytics.overview?.totalClubs ?? 0 }}</span>
                <span class="stat-label">总俱乐部数</span>
              </div>
              <div class="stat-card">
                <span class="stat-value">{{ analytics.overview?.totalPlayers ?? 0 }}</span>
                <span class="stat-label">总球员数</span>
              </div>
              <div class="stat-card">
                <span class="stat-value">{{ analytics.overview?.totalMatches ?? 0 }}</span>
                <span class="stat-label">总比赛数</span>
              </div>
              <div class="stat-card">
                <span class="stat-value">{{ analytics.overview?.totalRatings ?? 0 }}</span>
                <span class="stat-label">总评分数</span>
              </div>
              <div class="stat-card">
                <span class="stat-value">{{ analytics.overview?.totalNews ?? 0 }}</span>
                <span class="stat-label">总新闻数</span>
              </div>
              <div class="stat-card">
                <span class="stat-value">{{ analytics.overview?.totalGoals ?? 0 }}</span>
                <span class="stat-label">总进球数</span>
              </div>
              <div class="stat-card">
                <span class="stat-value">{{ analytics.overview?.totalAssists ?? 0 }}</span>
                <span class="stat-label">总助攻数</span>
              </div>
            </div>

            <div class="stats-row-3">
              <div class="stat-card-sm">
                <span class="stat-value-sm">{{ analytics.overview?.finishedMatches ?? 0 }}</span>
                <span class="stat-label">已结束</span>
              </div>
              <div class="stat-card-sm">
                <span class="stat-value-sm">{{ analytics.overview?.inProgressMatches ?? 0 }}</span>
                <span class="stat-label">进行中</span>
              </div>
              <div class="stat-card-sm">
                <span class="stat-value-sm">{{ analytics.overview?.pendingMatches ?? 0 }}</span>
                <span class="stat-label">未开始</span>
              </div>
              <div class="stat-card-sm">
                <span class="stat-value-sm">{{ analytics.overview?.totalYellowCards ?? 0 }}</span>
                <span class="stat-label">黄牌</span>
              </div>
              <div class="stat-card-sm">
                <span class="stat-value-sm">{{ analytics.overview?.totalRedCards ?? 0 }}</span>
                <span class="stat-label">红牌</span>
              </div>
              <div class="stat-card-sm">
                <span class="stat-value-sm">{{ analytics.overview?.activePlayers ?? 0 }}</span>
                <span class="stat-label">活跃球员</span>
              </div>
              <div class="stat-card-sm">
                <span class="stat-value-sm">{{ analytics.overview?.injuredPlayers ?? 0 }}</span>
                <span class="stat-label">受伤球员</span>
              </div>
            </div>

            <div class="analytics-charts-row">
              <div class="analytics-chart-card">
                <h4>联赛数据对比</h4>
                <el-table :data="analytics.leagueStats" size="small" style="margin-top:8px">
                  <el-table-column prop="league" label="联赛" />
                  <el-table-column prop="clubCount" label="俱乐部" width="80" />
                  <el-table-column prop="playerCount" label="球员" width="80" />
                  <el-table-column prop="matchCount" label="比赛" width="80" />
                  <el-table-column prop="totalGoals" label="进球" width="80" />
                </el-table>
              </div>
              <div class="analytics-chart-card">
                <h4>球员位置分布</h4>
                <div v-for="pos in analytics.positionDist" :key="pos.position" class="bar-row">
                  <span class="bar-label">{{ pos.position }}</span>
                  <div class="bar-track">
                    <div class="bar-fill" :style="{ width: posBarWidth(pos.count) }"></div>
                  </div>
                  <span class="bar-count">{{ pos.count }}</span>
                </div>
              </div>
              <div class="analytics-chart-card">
                <h4>月度比赛趋势</h4>
                <el-table :data="analytics.monthlyMatches" size="small" style="margin-top:8px">
                  <el-table-column prop="month" label="月份" width="90" />
                  <el-table-column prop="matchCount" label="比赛数" width="80" />
                  <el-table-column prop="goalCount" label="进球数" width="80" />
                </el-table>
              </div>
            </div>
          </div>
          <div v-else style="text-align:center;padding:40px;color:var(--color-text-muted)">加载中...</div>
        </el-tab-pane>

        <el-tab-pane label="用户管理" name="users">
          <div class="toolbar">
            <el-select v-model="userFilterRole" placeholder="角色筛选" clearable style="width:150px" @change="fetchUsers">
              <el-option label="超级管理员" value="SUPER_ADMIN" />
              <el-option label="俱乐部管理员" value="CLUB_ADMIN" />
              <el-option label="球迷" value="FAN" />
            </el-select>
            <el-input v-model="userKeyword" placeholder="搜索用户名/昵称" clearable style="width:200px" @keyup.enter="fetchUsers" />
            <el-button type="primary" @click="fetchUsers">搜索</el-button>
          </div>
          <el-table :data="users">
            <el-table-column prop="userId" label="ID" width="70" />
            <el-table-column prop="username" label="用户名" width="130" />
            <el-table-column prop="nickname" label="昵称" width="130" />
            <el-table-column prop="role" label="角色" width="120">
              <template #default="{ row }">
                <el-select v-model="row.role" size="small" @change="handleRoleChange(row.userId, row.role)">
                  <el-option label="超级管理员" value="SUPER_ADMIN" />
                  <el-option label="俱乐部管理员" value="CLUB_ADMIN" />
                  <el-option label="球迷" value="FAN" />
                </el-select>
              </template>
            </el-table-column>
            <el-table-column prop="managedClubId" label="管理俱乐部" width="130">
              <template #default="{ row }">
                <el-select v-if="row.role === 'CLUB_ADMIN'" v-model="row.managedClubId" size="small" placeholder="分配俱乐部" @change="handleAssignClub(row.userId, row.managedClubId)">
                  <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
                </el-select>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'danger'" size="small">
                  {{ row.status === 'ACTIVE' ? '正常' : '禁用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button v-if="row.status === 'ACTIVE'" type="danger" size="small" @click="toggleUserStatus(row.userId, 'DISABLED')">禁用</el-button>
                <el-button v-else type="success" size="small" @click="toggleUserStatus(row.userId, 'ACTIVE')">启用</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="userPage" :page-size="pageSize" :total="userTotal" layout="prev, pager, next" @current-change="fetchUsers" />
          </div>
        </el-tab-pane>

        <el-tab-pane label="比赛管理" name="matches">
          <div class="toolbar">
            <el-select v-model="matchFilterLeague" placeholder="联赛筛选" clearable style="width:160px" @change="fetchMatches">
              <el-option label="Premier League" value="Premier League" />
              <el-option label="La Liga" value="La Liga" />
              <el-option label="Bundesliga" value="Bundesliga" />
              <el-option label="Serie A" value="Serie A" />
              <el-option label="Ligue 1" value="Ligue 1" />
            </el-select>
            <el-select v-model="matchFilterStatus" placeholder="状态筛选" clearable style="width:120px" @change="fetchMatches">
              <el-option label="未开始" value="PENDING" />
              <el-option label="进行中" value="IN_PROGRESS" />
              <el-option label="已结束" value="FINISHED" />
            </el-select>
            <el-button type="primary" @click="openMatchDialog()">新增比赛</el-button>
          </div>
          <el-table :data="matches">
            <el-table-column prop="matchId" label="ID" width="90" />
            <el-table-column label="主队" width="130">
              <template #default="{ row }">{{ getClubName(row.homeClubId) }}</template>
            </el-table-column>
            <el-table-column label="比分" width="80">
              <template #default="{ row }">{{ row.homeScore ?? '-' }} : {{ row.awayScore ?? '-' }}</template>
            </el-table-column>
            <el-table-column label="客队" width="130">
              <template #default="{ row }">{{ getClubName(row.awayClubId) }}</template>
            </el-table-column>
            <el-table-column prop="league" label="联赛" width="130" />
            <el-table-column prop="status" label="状态" width="90">
              <template #default="{ row }">
                <el-tag :type="matchStatusType(row.status)" size="small">{{ matchStatusMap[row.status] || row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="比赛时间" width="160">
              <template #default="{ row }">{{ formatTime(row.matchTime) }}</template>
            </el-table-column>
            <el-table-column label="操作" width="200">
              <template #default="{ row }">
                <el-button v-if="row.status !== 'FINISHED'" type="warning" size="small" @click="openFinishDialog(row)">结束比赛</el-button>
                <el-button size="small" @click="openMatchDialog(row)">编辑</el-button>
                <el-button type="danger" size="small" @click="handleDeleteMatch(row.matchId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="matchPage" :page-size="pageSize" :total="matchTotal" layout="prev, pager, next" @current-change="fetchMatches" />
          </div>
        </el-tab-pane>

        <el-tab-pane label="转会管理" name="transfers">
          <div class="toolbar">
            <el-select v-model="transferFilterType" placeholder="转会类型" clearable style="width:120px" @change="fetchTransfers">
              <el-option label="转入" value="IN" />
              <el-option label="转出" value="OUT" />
              <el-option label="租借" value="LOAN" />
              <el-option label="自由身" value="FREE" />
            </el-select>
            <el-button type="primary" @click="openTransferDialog()">新增转会</el-button>
          </div>
          <el-table :data="transfers">
            <el-table-column prop="logId" label="ID" width="70" />
            <el-table-column label="球员" width="130">
              <template #default="{ row }">{{ getPlayerName(row.playerId) }}</template>
            </el-table-column>
            <el-table-column label="原俱乐部" width="130">
              <template #default="{ row }">{{ row.oldClubId ? getClubName(row.oldClubId) : '无' }}</template>
            </el-table-column>
            <el-table-column label="新俱乐部" width="130">
              <template #default="{ row }">{{ row.newClubId ? getClubName(row.newClubId) : '无' }}</template>
            </el-table-column>
            <el-table-column prop="transferType" label="类型" width="80">
              <template #default="{ row }">{{ transferTypeMap[row.transferType] || row.transferType }}</template>
            </el-table-column>
            <el-table-column label="转会费" width="100">
              <template #default="{ row }">{{ row.transferFee ? (row.transferFee / 10000).toFixed(0) + '万' : '-' }}</template>
            </el-table-column>
            <el-table-column prop="season" label="赛季" width="80" />
            <el-table-column label="操作时间" width="160">
              <template #default="{ row }">{{ formatTime(row.actionTime) }}</template>
            </el-table-column>
            <el-table-column label="操作" width="80">
              <template #default="{ row }">
                <el-button type="danger" size="small" @click="handleDeleteTransfer(row.logId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="transferPage" :page-size="pageSize" :total="transferTotal" layout="prev, pager, next" @current-change="fetchTransfers" />
          </div>
        </el-tab-pane>

        <el-tab-pane label="俱乐部管理" name="clubs">
          <div class="toolbar">
            <el-button type="primary" @click="openClubDialog()">新增俱乐部</el-button>
          </div>
          <el-table :data="clubs">
            <el-table-column prop="clubId" label="ID" width="70" />
            <el-table-column prop="name" label="名称" min-width="150" />
            <el-table-column prop="shortName" label="简称" width="100" />
            <el-table-column prop="league" label="联赛" width="140" />
            <el-table-column prop="city" label="城市" width="100" />
            <el-table-column prop="stadium" label="主场" width="140" />
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button size="small" @click="openClubDialog(row)">编辑</el-button>
                <el-button type="danger" size="small" @click="handleDeleteClub(row.clubId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="clubPage" :page-size="pageSize" :total="clubTotal" layout="prev, pager, next" @current-change="fetchClubs" />
          </div>
        </el-tab-pane>

        <el-tab-pane label="数据导入导出" name="io">
          <div class="io-section">
            <h3 style="margin:0 0 16px;font-size:16px;color:var(--color-text-primary)">数据导出</h3>
            <div class="io-grid">
              <div class="io-card">
                <h4>俱乐部数据</h4>
                <p>导出所有俱乐部信息</p>
                <div style="display:flex;gap:8px;margin-top:12px">
                  <el-button type="primary" size="small" @click="handleExport('clubs', 'xlsx')">导出 Excel</el-button>
                  <el-button size="small" @click="handleExport('clubs', 'csv')">导出 CSV</el-button>
                </div>
              </div>
              <div class="io-card">
                <h4>球员数据</h4>
                <p>导出所有球员信息</p>
                <div style="display:flex;gap:8px;margin-top:12px">
                  <el-button type="primary" size="small" @click="handleExport('players', 'xlsx')">导出 Excel</el-button>
                  <el-button size="small" @click="handleExport('players', 'csv')">导出 CSV</el-button>
                </div>
              </div>
              <div class="io-card">
                <h4>比赛数据</h4>
                <p>导出所有比赛信息</p>
                <div style="display:flex;gap:8px;margin-top:12px">
                  <el-button type="primary" size="small" @click="handleExport('matches', 'xlsx')">导出 Excel</el-button>
                  <el-button size="small" @click="handleExport('matches', 'csv')">导出 CSV</el-button>
                </div>
              </div>
              <div class="io-card">
                <h4>积分榜数据</h4>
                <p>导出联赛积分榜</p>
                <div style="display:flex;gap:8px;margin-top:12px">
                  <el-button type="primary" size="small" @click="handleExport('standings', 'xlsx')">导出 Excel</el-button>
                  <el-button size="small" @click="handleExport('standings', 'csv')">导出 CSV</el-button>
                </div>
              </div>
              <div class="io-card">
                <h4>球员赛季统计</h4>
                <p>导出射手榜/助攻榜等</p>
                <div style="display:flex;gap:8px;margin-top:12px">
                  <el-button type="primary" size="small" @click="handleExport('playerStats', 'xlsx')">导出 Excel</el-button>
                  <el-button size="small" @click="handleExport('playerStats', 'csv')">导出 CSV</el-button>
                </div>
              </div>
            </div>

            <h3 style="margin:28px 0 16px;font-size:16px;color:var(--color-text-primary)">数据导入</h3>
            <div class="io-grid">
              <div class="io-card">
                <h4>导入球员</h4>
                <p>Excel格式：英文名、中文名、位置、俱乐部ID、号码、国籍、身高cm、体重kg、状态</p>
                <el-upload
                  :auto-upload="false"
                  :show-file-list="false"
                  accept=".xlsx,.xls"
                  :on-change="(f: any) => handleImport('players', f)"
                  style="margin-top:12px"
                >
                  <el-button type="success" size="small">选择文件并导入</el-button>
                </el-upload>
              </div>
              <div class="io-card">
                <h4>导入比赛</h4>
                <p>Excel格式：联赛、赛季、主队ID、客队ID、状态</p>
                <el-upload
                  :auto-upload="false"
                  :show-file-list="false"
                  accept=".xlsx,.xls"
                  :on-change="(f: any) => handleImport('matches', f)"
                  style="margin-top:12px"
                >
                  <el-button type="success" size="small">选择文件并导入</el-button>
                </el-upload>
              </div>
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="新闻管理" name="news">
          <div class="toolbar">
            <el-input v-model="newsKeyword" placeholder="搜索新闻标题" clearable style="width:200px" @keyup.enter="fetchNews" />
            <el-select v-model="newsFilterClub" placeholder="俱乐部筛选" clearable style="width:160px" @change="fetchNews">
              <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
            </el-select>
            <el-button type="primary" @click="fetchNews">搜索</el-button>
            <el-button type="success" @click="openNewsDialog()">新增新闻</el-button>
          </div>
          <el-table :data="newsList">
            <el-table-column prop="articleId" label="ID" width="70" />
            <el-table-column prop="title" label="标题" min-width="200" show-overflow-tooltip />
            <el-table-column prop="sourceName" label="来源" width="100" />
            <el-table-column label="俱乐部" width="120">
              <template #default="{ row }">{{ row.clubId ? getClubName(row.clubId) : '-' }}</template>
            </el-table-column>
            <el-table-column prop="viewCount" label="阅读" width="70" />
            <el-table-column prop="isPublished" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="row.isPublished === 1 ? 'success' : 'info'" size="small">
                  {{ row.isPublished === 1 ? '已发布' : '草稿' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="发布时间" width="160">
              <template #default="{ row }">{{ formatTime(row.publishedAt) }}</template>
            </el-table-column>
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button size="small" @click="openNewsDialog(row)">编辑</el-button>
                <el-button type="danger" size="small" @click="handleDeleteNews(row.articleId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="newsPage" :page-size="pageSize" :total="newsTotal" layout="prev, pager, next" @current-change="fetchNews" />
          </div>
        </el-tab-pane>
        <el-tab-pane label="球员管理" name="players">
          <div class="toolbar">
            <el-select v-model="playerFilterClub" placeholder="俱乐部筛选" clearable style="width:160px" @change="fetchPlayers">
              <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
            </el-select>
            <el-input v-model="playerKeyword" placeholder="搜索球员" clearable style="width:180px" @keyup.enter="fetchPlayers" />
            <el-button type="primary" @click="fetchPlayers">搜索</el-button>
            <el-button type="success" @click="openPlayerDialog()">新增球员</el-button>
          </div>
          <el-table :data="players">
            <el-table-column prop="playerId" label="ID" width="70" />
            <el-table-column prop="nameCn" label="中文名" width="100" />
            <el-table-column prop="name" label="英文名" width="120" />
            <el-table-column label="俱乐部" width="120">
              <template #default="{ row }">{{ getClubName(row.clubId) }}</template>
            </el-table-column>
            <el-table-column prop="position" label="位置" width="70" />
            <el-table-column prop="jerseyNumber" label="号码" width="60" />
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'info'" size="small">{{ playerStatusMap[row.status] || row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="avgScore" label="评分" width="70" />
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button size="small" @click="openPlayerDialog(row)">编辑</el-button>
                <el-button type="danger" size="small" @click="handleDeletePlayer(row.playerId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="playerPage" :page-size="pageSize" :total="playerTotal" layout="prev, pager, next" @current-change="fetchPlayers" />
          </div>
        </el-tab-pane>
        <el-tab-pane label="社区管理" name="community">
          <div class="toolbar">
            <el-select v-model="postFilterCircle" placeholder="圈子筛选" clearable style="width:160px" @change="fetchPosts">
              <el-option label="主社区" :value="0" />
              <el-option v-for="c in circles" :key="c.circleId" :label="c.name" :value="c.circleId" />
            </el-select>
            <el-input v-model="postKeyword" placeholder="搜索帖子内容" clearable style="width:200px" @keyup.enter="fetchPosts" />
            <el-button type="primary" @click="fetchPosts">搜索</el-button>
          </div>
          <el-table :data="posts">
            <el-table-column prop="postId" label="ID" width="70" />
            <el-table-column label="发布者" width="120">
              <template #default="{ row }">
                <div class="post-user-cell">
                  <span class="user-name">{{ row.userNickname }}</span>
                  <span v-if="row.userFavoriteClubName" class="user-club-sm">{{ row.userFavoriteClubName }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="content" label="内容" min-width="250" show-overflow-tooltip />
            <el-table-column label="圈子" width="100">
              <template #default="{ row }">
                <el-tag v-if="row.circleName" size="small" type="info">{{ row.circleName }}</el-tag>
                <span v-else>主社区</span>
              </template>
            </el-table-column>
            <el-table-column label="统计" width="100">
              <template #default="{ row }">
                <span class="stat-sm">👍{{ row.likeCount || 0 }}</span>
                <span class="stat-sm">⭐{{ row.favoriteCount || 0 }}</span>
              </template>
            </el-table-column>
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-tag v-if="row.isPinned" type="warning" size="small">置顶</el-tag>
                <el-tag v-if="row.isEssence" type="success" size="small">精华</el-tag>
                <span v-if="!row.isPinned && !row.isEssence">-</span>
              </template>
            </el-table-column>
            <el-table-column label="发布时间" width="140">
              <template #default="{ row }">{{ formatTime(row.createdAt) }}</template>
            </el-table-column>
            <el-table-column label="操作" width="200">
              <template #default="{ row }">
                <el-button v-if="!row.isPinned" type="warning" size="small" @click="handlePinPost(row.postId, true)">置顶</el-button>
                <el-button v-else size="small" @click="handlePinPost(row.postId, false)">取消置顶</el-button>
                <el-button v-if="!row.isEssence" type="success" size="small" @click="handleEssencePost(row.postId, true)">精华</el-button>
                <el-button v-else size="small" @click="handleEssencePost(row.postId, false)">取消精华</el-button>
                <el-button type="danger" size="small" @click="handleDeletePost(row.postId)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <div class="pagination-wrapper">
            <el-pagination v-model:current-page="postPage" :page-size="pageSize" :total="postTotal" layout="prev, pager, next" @current-change="fetchPosts" />
          </div>
        </el-tab-pane>
        <el-tab-pane label="赛季管理" name="seasons">
          <div class="season-section">
            <div class="season-header">
              <h3>当前赛季</h3>
              <el-button type="primary" @click="showStartNewSeasonDialog">开启新赛季</el-button>
            </div>
            <el-table :data="activeSeasons" stripe>
              <el-table-column prop="league" label="联赛" width="150" />
              <el-table-column prop="seasonName" label="赛季名称" width="120" />
              <el-table-column prop="totalRounds" label="总轮数" width="80" />
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'info'" size="small">{{ row.status === 'ACTIVE' ? '进行中' : row.status }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="startYear" label="开始年份" width="100" />
              <el-table-column prop="endYear" label="结束年份" width="100" />
              <el-table-column label="操作" width="250">
                <template #default="{ row }">
                  <el-button type="warning" size="small" @click="handleResetSeason(row.league)">重置数据</el-button>
                  <el-button type="info" size="small" @click="handleFinishSeason(row.league)">结束赛季</el-button>
                </template>
              </el-table-column>
            </el-table>

            <div class="season-history" style="margin-top: 30px;">
              <h3>历史赛季</h3>
              <el-table :data="allSeasons.filter(s => s.status !== 'ACTIVE')" stripe>
                <el-table-column prop="league" label="联赛" width="150" />
                <el-table-column prop="seasonName" label="赛季名称" width="120" />
                <el-table-column prop="totalRounds" label="总轮数" width="80" />
                <el-table-column prop="status" label="状态" width="100">
                  <template #default="{ row }">
                    <el-tag :type="row.status === 'FINISHED' ? 'info' : 'default'" size="small">{{ row.status }}</el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="startYear" label="开始年份" width="100" />
                <el-table-column prop="endYear" label="结束年份" width="100" />
              </el-table>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <el-dialog v-model="matchDialogVisible" :title="matchForm.matchId ? '编辑比赛' : '新增比赛'" width="550px">
      <el-form :model="matchForm" label-width="90px">
        <el-form-item label="比赛ID" v-if="!matchForm.matchId">
          <el-input v-model="matchForm.matchId" placeholder="如 EPL007" />
        </el-form-item>
        <el-form-item label="主队">
          <el-select v-model="matchForm.homeClubId" placeholder="选择主队" style="width:100%">
            <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
          </el-select>
        </el-form-item>
        <el-form-item label="客队">
          <el-select v-model="matchForm.awayClubId" placeholder="选择客队" style="width:100%">
            <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
          </el-select>
        </el-form-item>
        <el-form-item label="比赛时间">
          <el-date-picker v-model="matchForm.matchTime" type="datetime" placeholder="选择时间" style="width:100%" />
        </el-form-item>
        <el-form-item label="联赛">
          <el-input v-model="matchForm.league" />
        </el-form-item>
        <el-form-item label="赛季">
          <el-input v-model="matchForm.season" placeholder="如 2024-2025" />
        </el-form-item>
        <el-form-item label="轮次">
          <el-input v-model="matchForm.round" />
        </el-form-item>
        <el-form-item label="场地">
          <el-input v-model="matchForm.venue" />
        </el-form-item>
        <el-form-item label="裁判">
          <el-input v-model="matchForm.referee" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="matchForm.status" style="width:100%">
            <el-option label="未开始" value="PENDING" />
            <el-option label="进行中" value="IN_PROGRESS" />
            <el-option label="已结束" value="FINISHED" />
          </el-select>
        </el-form-item>
        <el-form-item label="主队比分" v-if="matchForm.status !== 'PENDING'">
          <el-input-number v-model="matchForm.homeScore" :min="0" />
        </el-form-item>
        <el-form-item label="客队比分" v-if="matchForm.status !== 'PENDING'">
          <el-input-number v-model="matchForm.awayScore" :min="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="matchDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveMatch">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="finishDialogVisible" title="结束比赛" width="750px" :close-on-click-modal="false">
      <div v-if="finishMatch" style="margin-bottom:16px">
        <el-descriptions :column="2" border size="small">
          <el-descriptions-item label="主队">{{ getClubName(finishMatch.homeClubId) }}</el-descriptions-item>
          <el-descriptions-item label="客队">{{ getClubName(finishMatch.awayClubId) }}</el-descriptions-item>
          <el-descriptions-item label="联赛">{{ finishMatch.league }}</el-descriptions-item>
          <el-descriptions-item label="赛季">{{ finishMatch.season }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <el-form label-width="90px">
        <el-form-item label="比分">
          <div style="display:flex;align-items:center;gap:12px">
            <el-input-number v-model="finishForm.homeScore" :min="0" placeholder="主队" />
            <span>:</span>
            <el-input-number v-model="finishForm.awayScore" :min="0" placeholder="客队" />
          </div>
        </el-form-item>
        <el-divider content-position="left">比赛事件</el-divider>
        <div v-for="(evt, idx) in finishForm.events" :key="idx" style="display:flex;gap:8px;margin-bottom:8px;align-items:center;flex-wrap:wrap">
          <el-select v-model="evt.eventType" placeholder="类型" style="width:120px">
            <el-option label="进球" value="GOAL" />
            <el-option label="点球" value="PENALTY" />
            <el-option label="乌龙球" value="OWN_GOAL" />
            <el-option label="黄牌" value="YELLOW_CARD" />
            <el-option label="红牌" value="RED_CARD" />
          </el-select>
          <el-select v-model="evt.clubId" placeholder="所属球队" style="width:140px" v-if="finishMatch">
            <el-option :label="getClubName(finishMatch.homeClubId)" :value="finishMatch.homeClubId" />
            <el-option :label="getClubName(finishMatch.awayClubId)" :value="finishMatch.awayClubId" />
          </el-select>
          <el-select v-model="evt.playerId" placeholder="球员" filterable style="width:140px">
            <el-option v-for="p in getPlayersByClub(evt.clubId)" :key="p.playerId" :label="p.nameCn || p.name" :value="p.playerId" />
          </el-select>
          <el-input-number v-model="evt.matchMinute" :min="1" :max="120" placeholder="分钟" style="width:100px" />
          <el-select v-if="evt.eventType === 'GOAL' || evt.eventType === 'PENALTY'" v-model="evt.assistPlayerId" placeholder="助攻球员" filterable clearable style="width:140px">
            <el-option v-for="p in getPlayersByClub(evt.clubId)" :key="p.playerId" :label="p.nameCn || p.name" :value="p.playerId" />
          </el-select>
          <el-button type="danger" size="small" @click="finishForm.events.splice(idx, 1)" circle>×</el-button>
        </div>
        <el-button type="primary" size="small" @click="addFinishEvent">+ 添加事件</el-button>
      </el-form>
      <template #footer>
        <el-button @click="finishDialogVisible = false">取消</el-button>
        <el-button type="danger" @click="handleFinishMatch">确认结束比赛</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="transferDialogVisible" title="新增转会" width="500px">
      <el-form :model="transferForm" label-width="90px">
        <el-form-item label="球员">
          <el-select v-model="transferForm.playerId" placeholder="选择球员" filterable style="width:100%" @change="onTransferPlayerChange">
            <el-option v-for="p in allPlayers" :key="p.playerId" :label="p.nameCn || p.name" :value="p.playerId" />
          </el-select>
        </el-form-item>
        <el-form-item label="新俱乐部">
          <el-select v-model="transferForm.newClubId" placeholder="选择新俱乐部" style="width:100%">
            <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
          </el-select>
        </el-form-item>
        <el-form-item label="转会类型">
          <el-select v-model="transferForm.transferType" style="width:100%">
            <el-option label="转入" value="IN" />
            <el-option label="转出" value="OUT" />
            <el-option label="租借" value="LOAN" />
            <el-option label="自由身" value="FREE" />
          </el-select>
        </el-form-item>
        <el-form-item label="转会费">
          <el-input-number v-model="transferForm.transferFee" :min="0" :step="1000000" style="width:100%" />
        </el-form-item>
        <el-form-item label="赛季">
          <el-input v-model="transferForm.season" placeholder="如 2024-2025" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="transferForm.notes" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="transferDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveTransfer">确认转会</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="clubDialogVisible" :title="clubForm.clubId ? '编辑俱乐部' : '新增俱乐部'" width="550px">
      <el-form :model="clubForm" label-width="90px">
        <el-form-item label="俱乐部Logo">
          <ImageUpload v-model="clubForm.logoUrl" placeholder="上传Logo" alt="俱乐部Logo" />
        </el-form-item>
        <el-form-item label="名称">
          <el-input v-model="clubForm.name" />
        </el-form-item>
        <el-form-item label="简称">
          <el-input v-model="clubForm.shortName" />
        </el-form-item>
        <el-form-item label="联赛">
          <el-select v-model="clubForm.league" placeholder="选择或输入联赛" filterable allow-create clearable style="width:100%">
            <el-option v-for="l in availableLeagues" :key="l" :label="l" :value="l" />
          </el-select>
        </el-form-item>
        <el-form-item label="城市">
          <el-input v-model="clubForm.city" />
        </el-form-item>
        <el-form-item label="国家">
          <el-input v-model="clubForm.country" />
        </el-form-item>
        <el-form-item label="主场">
          <el-input v-model="clubForm.stadium" />
        </el-form-item>
        <el-form-item label="容量">
          <el-input-number v-model="clubForm.stadiumCapacity" :min="0" />
        </el-form-item>
        <el-form-item label="简介">
          <el-input v-model="clubForm.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="clubDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveClub">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="newsDialogVisible" :title="newsForm.articleId ? '编辑新闻' : '新增新闻'" width="650px">
      <el-form :model="newsForm" label-width="90px">
        <el-form-item label="标题">
          <el-input v-model="newsForm.title" />
        </el-form-item>
        <el-form-item label="摘要">
          <el-input v-model="newsForm.summary" type="textarea" :rows="2" />
        </el-form-item>
        <el-form-item label="内容">
          <el-input v-model="newsForm.content" type="textarea" :rows="5" />
        </el-form-item>
        <el-form-item label="来源名称">
          <el-input v-model="newsForm.sourceName" placeholder="如：懂球帝、新浪体育" />
        </el-form-item>
        <el-form-item label="来源链接">
          <el-input v-model="newsForm.sourceUrl" placeholder="https://..." />
        </el-form-item>
        <el-form-item label="关联俱乐部">
          <el-select v-model="newsForm.clubId" placeholder="选择俱乐部" clearable style="width:100%">
            <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
          </el-select>
        </el-form-item>
        <el-form-item label="标签">
          <el-input v-model="newsForm.tags" placeholder="多个标签用逗号分隔" />
        </el-form-item>
        <el-form-item label="封面图">
          <ImageUpload v-model="newsForm.coverImageUrl" placeholder="上传封面" alt="封面图" />
        </el-form-item>
        <el-form-item label="发布状态">
          <el-select v-model="newsForm.isPublished" style="width:100%">
            <el-option label="已发布" :value="1" />
            <el-option label="草稿" :value="0" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="newsDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveNews">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="playerDialogVisible" :title="playerForm.playerId ? '编辑球员' : '新增球员'" width="550px">
      <el-form :model="playerForm" label-width="90px">
        <el-form-item label="球员头像">
          <ImageUpload v-model="playerForm.avatarUrl" placeholder="上传头像" alt="球员头像" />
        </el-form-item>
        <el-form-item label="英文名">
          <el-input v-model="playerForm.name" />
        </el-form-item>
        <el-form-item label="中文名">
          <el-input v-model="playerForm.nameCn" />
        </el-form-item>
        <el-form-item label="俱乐部">
          <el-select v-model="playerForm.clubId" placeholder="选择俱乐部" style="width:100%">
            <el-option v-for="c in allClubs" :key="c.clubId" :label="c.shortName || c.name" :value="c.clubId" />
          </el-select>
        </el-form-item>
        <el-form-item label="位置">
          <el-select v-model="playerForm.position" style="width:100%">
            <el-option label="门将" value="GK" />
            <el-option label="后卫" value="DEF" />
            <el-option label="中场" value="MID" />
            <el-option label="前锋" value="FWD" />
          </el-select>
        </el-form-item>
        <el-form-item label="号码">
          <el-input-number v-model="playerForm.jerseyNumber" :min="0" :max="99" />
        </el-form-item>
        <el-form-item label="国籍">
          <el-input v-model="playerForm.nationality" />
        </el-form-item>
        <el-form-item label="身高(cm)">
          <el-input-number v-model="playerForm.heightCm" :min="0" />
        </el-form-item>
        <el-form-item label="体重(kg)">
          <el-input-number v-model="playerForm.weightKg" :min="0" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="playerForm.status" style="width:100%">
            <el-option label="活跃" value="ACTIVE" />
            <el-option label="受伤" value="INJURED" />
            <el-option label="自由身" value="FREE" />
            <el-option label="退役" value="RETIRED" />
          </el-select>
        </el-form-item>
        <el-form-item label="身价">
          <el-input-number v-model="playerForm.marketValue" :min="0" :step="1000000" style="width:100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="playerDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSavePlayer">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="newSeasonDialogVisible" title="开启新赛季" width="450px">
      <el-form :model="newSeasonForm" label-width="100px">
        <el-form-item label="联赛" required>
          <el-select v-model="newSeasonForm.league" placeholder="选择或输入联赛名称" allow-create filterable style="width:100%">
            <el-option label="Premier League" value="Premier League" />
            <el-option label="La Liga" value="La Liga" />
            <el-option label="Serie A" value="Serie A" />
            <el-option label="Bundesliga" value="Bundesliga" />
            <el-option label="Ligue 1" value="Ligue 1" />
            <el-option label="Chinese Super League" value="Chinese Super League" />
          </el-select>
        </el-form-item>
        <el-form-item label="赛季名称" required>
          <el-input v-model="newSeasonForm.seasonName" placeholder="如 2026-2027" />
        </el-form-item>
        <el-form-item label="总轮数">
          <el-input-number v-model="newSeasonForm.totalRounds" :min="10" :max="60" />
        </el-form-item>
        <el-alert type="warning" :closable="false" style="margin-top: 10px;">
          开启新赛季将自动结束当前赛季，并清空积分榜、球员数据和比赛数据！
        </el-alert>
      </el-form>
      <template #footer>
        <el-button @click="newSeasonDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleStartNewSeason">确认开启</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { adminApi, clubApi, playerApi, newsApi, analyticsApi, socialApi, seasonApi } from '@/api'
import ImageUpload from '@/components/ImageUpload.vue'

const activeTab = ref('stats')
const pageSize = ref(20)

const analytics = ref<any>(null)

const users = ref<any[]>([])
const userPage = ref(1)
const userTotal = ref(0)
const userFilterRole = ref('')
const userKeyword = ref('')

const matches = ref<any[]>([])
const matchPage = ref(1)
const matchTotal = ref(0)
const matchFilterLeague = ref('')
const matchFilterStatus = ref('')

const transfers = ref<any[]>([])
const transferPage = ref(1)
const transferTotal = ref(0)
const transferFilterType = ref('')

const clubs = ref<any[]>([])
const clubPage = ref(1)
const clubTotal = ref(0)

const players = ref<any[]>([])
const playerPage = ref(1)
const playerTotal = ref(0)
const playerFilterClub = ref<any>('')
const playerKeyword = ref('')

const newsList = ref<any[]>([])
const newsPage = ref(1)
const newsTotal = ref(0)
const newsKeyword = ref('')
const newsFilterClub = ref<any>('')
const newsDialogVisible = ref(false)
const newsForm = ref<any>({})

const allClubs = ref<any[]>([])
const allPlayers = ref<any[]>([])

const matchDialogVisible = ref(false)
const matchForm = ref<any>({})

const finishDialogVisible = ref(false)
const finishMatch = ref<any>(null)
const finishForm = ref<any>({ homeScore: 0, awayScore: 0, events: [] })

const transferDialogVisible = ref(false)
const transferForm = ref<any>({})

const clubDialogVisible = ref(false)
const clubForm = ref<any>({})
const availableLeagues = ref<string[]>([])

const playerDialogVisible = ref(false)
const playerForm = ref<any>({})

const matchStatusMap: Record<string, string> = { PENDING: '未开始', IN_PROGRESS: '进行中', FINISHED: '已结束' }
const transferTypeMap: Record<string, string> = { IN: '转入', OUT: '转出', LOAN: '租借', FREE: '自由身' }
const playerStatusMap: Record<string, string> = { ACTIVE: '活跃', INJURED: '受伤', FREE: '自由身', RETIRED: '退役' }

const posts = ref<any[]>([])
const postPage = ref(1)
const postTotal = ref(0)
const postFilterCircle = ref<any>('')
const postKeyword = ref('')
const circles = ref<any[]>([])

const allSeasons = ref<any[]>([])
const activeSeasons = ref<any[]>([])
const newSeasonDialogVisible = ref(false)
const newSeasonForm = ref<any>({ league: '', seasonName: '', totalRounds: 38 })

function matchStatusType(status: string) {
  if (status === 'FINISHED') return 'success'
  if (status === 'IN_PROGRESS') return 'warning'
  return 'info'
}

function getClubName(clubId: number) {
  const club = allClubs.value.find(c => c.clubId === clubId)
  return club ? (club.shortName || club.name) : `#${clubId}`
}

function getPlayerName(playerId: number) {
  const p = allPlayers.value.find(p => p.playerId === playerId)
  return p ? (p.nameCn || p.name) : `#${playerId}`
}

function formatTime(time: string) {
  if (!time) return ''
  return new Date(time).toLocaleString('zh-CN', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false })
}

watch(activeTab, (tab) => {
  if (tab === 'stats') fetchStats()
  if (tab === 'users' && users.value.length === 0) fetchUsers()
  if (tab === 'matches' && matches.value.length === 0) fetchMatches()
  if (tab === 'transfers' && transfers.value.length === 0) fetchTransfers()
  if (tab === 'clubs' && clubs.value.length === 0) fetchClubs()
  if (tab === 'news' && newsList.value.length === 0) fetchNews()
  if (tab === 'players' && players.value.length === 0) fetchPlayers()
  if (tab === 'community' && posts.value.length === 0) { fetchPosts(); fetchCircles() }
  if (tab === 'seasons') { fetchAllSeasons(); fetchActiveSeasons() }
})

onMounted(() => {
  fetchStats()
  fetchAllClubs()
  fetchAllPlayers()
})

async function fetchAllClubs() {
  try {
    const res = await clubApi.list({ page: 1, pageSize: 200 })
    allClubs.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}

async function fetchAllPlayers() {
  try {
    const res = await playerApi.list({ page: 1, pageSize: 500 })
    allPlayers.value = res.data.data?.records || []
  } catch (e) { console.error(e) }
}

async function fetchStats() {
  try {
    const res = await analyticsApi.getStats()
    analytics.value = res.data.data
  } catch (e) { console.error(e) }
}

async function fetchUsers() {
  try {
    const res = await adminApi.listUsers({ page: userPage.value, pageSize: pageSize.value, role: userFilterRole.value || undefined, keyword: userKeyword.value || undefined })
    users.value = res.data.data?.records || []
    userTotal.value = res.data.data?.total || 0
  } catch (e) { console.error(e) }
}

async function fetchMatches() {
  try {
    const res = await adminApi.listMatches({ page: matchPage.value, pageSize: pageSize.value, league: matchFilterLeague.value || undefined, status: matchFilterStatus.value || undefined })
    matches.value = res.data.data?.records || []
    matchTotal.value = res.data.data?.total || 0
  } catch (e) { console.error(e) }
}

async function fetchTransfers() {
  try {
    const res = await adminApi.listTransfers({ page: transferPage.value, pageSize: pageSize.value, transferType: transferFilterType.value || undefined })
    transfers.value = res.data.data?.records || []
    transferTotal.value = res.data.data?.total || 0
  } catch (e) { console.error(e) }
}

async function fetchClubs() {
  try {
    const res = await adminApi.listClubs({ page: clubPage.value, pageSize: pageSize.value })
    clubs.value = res.data.data?.records || []
    clubTotal.value = res.data.data?.total || 0
  } catch (e) { console.error(e) }
}

async function fetchPlayers() {
  try {
    const res = await adminApi.listPlayers({ page: playerPage.value, pageSize: pageSize.value, clubId: playerFilterClub.value || undefined, keyword: playerKeyword.value || undefined })
    players.value = res.data.data?.records || []
    playerTotal.value = res.data.data?.total || 0
  } catch (e) { console.error(e) }
}

async function toggleUserStatus(userId: number, status: string) {
  try {
    await adminApi.updateStatus(userId, status)
    ElMessage.success(status === 'ACTIVE' ? '用户已启用' : '用户已禁用')
    fetchUsers()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '操作失败') }
}

async function handleRoleChange(userId: number, role: string) {
  try {
    await adminApi.updateRole(userId, role)
    ElMessage.success('角色已更新')
    fetchUsers()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '操作失败') }
}

async function handleAssignClub(userId: number, managedClubId: number) {
  try {
    await adminApi.assignClub(userId, managedClubId)
    ElMessage.success('俱乐部已分配')
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '操作失败') }
}

function openMatchDialog(row?: any) {
  if (row) {
    matchForm.value = { ...row }
  } else {
    matchForm.value = { matchId: '', homeClubId: null, awayClubId: null, matchTime: null, league: '', season: '2024-2025', round: '', venue: '', referee: '', status: 'PENDING', homeScore: null, awayScore: null }
  }
  matchDialogVisible.value = true
}

async function handleSaveMatch() {
  try {
    if (matchForm.value.matchId && matches.value.some(m => m.matchId === matchForm.value.matchId)) {
      await adminApi.updateMatch(matchForm.value.matchId, matchForm.value)
    } else {
      await adminApi.createMatch(matchForm.value)
    }
    ElMessage.success('比赛已保存')
    matchDialogVisible.value = false
    fetchMatches()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '保存失败') }
}

async function handleDeleteMatch(matchId: string) {
  try {
    await ElMessageBox.confirm('确定删除该比赛？', '确认', { type: 'warning' })
    await adminApi.deleteMatch(matchId)
    ElMessage.success('比赛已删除')
    fetchMatches()
  } catch { }
}

function getPlayersByClub(clubId: number | null) {
  if (!clubId) return allPlayers.value
  return allPlayers.value.filter((p: any) => p.clubId === clubId)
}

function openFinishDialog(row: any) {
  finishMatch.value = row
  finishForm.value = {
    matchId: row.matchId,
    homeScore: row.homeScore ?? 0,
    awayScore: row.awayScore ?? 0,
    events: []
  }
  finishDialogVisible.value = true
}

function addFinishEvent() {
  finishForm.value.events.push({
    eventType: 'GOAL',
    playerId: null,
    assistPlayerId: null,
    clubId: finishMatch.value?.homeClubId || null,
    matchMinute: null
  })
}

async function handleFinishMatch() {
  if (finishForm.value.homeScore == null || finishForm.value.awayScore == null) {
    ElMessage.warning('请输入比分')
    return
  }
  try {
    await ElMessageBox.confirm(
      `确认结束比赛？比分 ${getClubName(finishMatch.value.homeClubId)} ${finishForm.value.homeScore} : ${finishForm.value.awayScore} ${getClubName(finishMatch.value.awayClubId)}，将自动更新积分榜和球员统计。`,
      '确认结束比赛',
      { type: 'warning' }
    )
    const payload = {
      matchId: finishForm.value.matchId,
      homeScore: finishForm.value.homeScore,
      awayScore: finishForm.value.awayScore,
      events: finishForm.value.events.filter((e: any) => e.playerId != null)
    }
    await adminApi.finishMatch(payload)
    ElMessage.success('比赛已结束，积分榜和球员统计已自动更新')
    finishDialogVisible.value = false
    fetchMatches()
  } catch (e: any) {
    if (e !== 'cancel') ElMessage.error(e.response?.data?.message || '操作失败')
  }
}

function openTransferDialog() {
  transferForm.value = { playerId: null, newClubId: null, transferType: 'OUT', transferFee: null, season: '2024-2025', notes: '' }
  transferDialogVisible.value = true
}

function onTransferPlayerChange(playerId: number) {
  const p = allPlayers.value.find(p => p.playerId === playerId)
  if (p && p.clubId) {
    transferForm.value.transferType = 'OUT'
  } else {
    transferForm.value.transferType = 'IN'
  }
}

async function handleSaveTransfer() {
  try {
    await adminApi.createTransfer(transferForm.value)
    ElMessage.success('转会已完成')
    transferDialogVisible.value = false
    fetchTransfers()
    fetchAllPlayers()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '转会失败') }
}

async function handleDeleteTransfer(logId: number) {
  try {
    await ElMessageBox.confirm('确定删除该转会记录？', '确认', { type: 'warning' })
    await adminApi.deleteTransfer(logId)
    ElMessage.success('记录已删除')
    fetchTransfers()
  } catch { }
}

async function fetchLeagues() {
  try {
    const res = await clubApi.getLeagues()
    availableLeagues.value = res.data.data || []
  } catch (e) { console.error(e) }
}

function openClubDialog(row?: any) {
  fetchLeagues()
  if (row) {
    clubForm.value = { ...row }
  } else {
    clubForm.value = { name: '', shortName: '', league: '', city: '', country: '', stadium: '', stadiumCapacity: null, description: '', logoUrl: '' }
  }
  clubDialogVisible.value = true
}

async function handleSaveClub() {
  try {
    if (clubForm.value.clubId) {
      await adminApi.updateClub(clubForm.value.clubId, clubForm.value)
    } else {
      await adminApi.createClub(clubForm.value)
    }
    ElMessage.success('俱乐部已保存')
    clubDialogVisible.value = false
    fetchClubs()
    fetchAllClubs()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '保存失败') }
}

async function handleDeleteClub(clubId: number) {
  try {
    await ElMessageBox.confirm('确定删除该俱乐部？', '确认', { type: 'warning' })
    await adminApi.deleteClub(clubId)
    ElMessage.success('俱乐部已删除')
    fetchClubs()
    fetchAllClubs()
  } catch { }
}

function openPlayerDialog(row?: any) {
  if (row) {
    playerForm.value = { ...row }
  } else {
    playerForm.value = { name: '', nameCn: '', clubId: null, position: 'MID', jerseyNumber: null, nationality: '', heightCm: null, weightKg: null, status: 'ACTIVE', marketValue: null, avatarUrl: '' }
  }
  playerDialogVisible.value = true
}

async function handleSavePlayer() {
  try {
    if (playerForm.value.playerId) {
      await adminApi.updatePlayer(playerForm.value.playerId, playerForm.value)
    } else {
      await adminApi.createPlayer(playerForm.value)
    }
    ElMessage.success('球员已保存')
    playerDialogVisible.value = false
    fetchPlayers()
    fetchAllPlayers()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '保存失败') }
}

async function handleDeletePlayer(playerId: number) {
  try {
    await ElMessageBox.confirm('确定删除该球员？', '确认', { type: 'warning' })
    await adminApi.deletePlayer(playerId)
    ElMessage.success('球员已删除')
    fetchPlayers()
    fetchAllPlayers()
  } catch { }
}

async function fetchNews() {
  try {
    const res = await newsApi.list({
      page: newsPage.value,
      pageSize: pageSize.value,
      keyword: newsKeyword.value || undefined,
      clubId: newsFilterClub.value || undefined
    })
    newsList.value = res.data.data?.records || []
    newsTotal.value = res.data.data?.total || 0
  } catch (e) { console.error(e) }
}

function openNewsDialog(row?: any) {
  if (row) {
    newsForm.value = { ...row }
  } else {
    newsForm.value = { title: '', summary: '', content: '', sourceName: '', sourceUrl: '', clubId: null, tags: '', coverImageUrl: '', isPublished: 1 }
  }
  newsDialogVisible.value = true
}

async function handleSaveNews() {
  try {
    if (newsForm.value.articleId) {
      await newsApi.update(newsForm.value.articleId, newsForm.value)
    } else {
      await newsApi.create(newsForm.value)
    }
    ElMessage.success('新闻已保存')
    newsDialogVisible.value = false
    fetchNews()
  } catch (e: any) { ElMessage.error(e.response?.data?.message || '保存失败') }
}

async function handleDeleteNews(articleId: number) {
  try {
    await ElMessageBox.confirm('确定删除该新闻？', '确认', { type: 'warning' })
    await newsApi.delete(articleId)
    ElMessage.success('新闻已删除')
    fetchNews()
  } catch { }
}

function posBarWidth(count: number) {
  if (!analytics.value?.positionDist?.length) return '0%'
  const max = Math.max(...analytics.value.positionDist.map((p: any) => p.count), 1)
  return Math.round((count / max) * 100) + '%'
}

async function handleExport(type: string, format: string) {
  try {
    const res = await analyticsApi.exportData(type, format)
    const blob = new Blob([res.data])
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${type}_${Date.now()}.${format}`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '导出失败')
  }
}

async function handleImport(type: string, file: any) {
  if (!file?.raw) return
  try {
    await ElMessageBox.confirm(`确认导入${type === 'players' ? '球员' : '比赛'}数据？`, '确认导入', { type: 'warning' })
    const apiFn = type === 'players' ? analyticsApi.importPlayers : analyticsApi.importMatches
    const res = await apiFn(file.raw)
    const count = res.data.data
    ElMessage.success(`成功导入 ${count} 条数据`)
    if (type === 'players') {
      fetchPlayers()
      fetchAllPlayers()
    } else {
      fetchMatches()
    }
  } catch (e: any) {
    if (e !== 'cancel') ElMessage.error(e.response?.data?.message || '导入失败')
  }
}

async function fetchCircles() {
  try {
    const res = await socialApi.getCircles()
    circles.value = res.data.data || []
  } catch (e) { console.error(e) }
}

async function fetchPosts() {
  try {
    const res = await socialApi.getPosts({
      page: postPage.value,
      pageSize: pageSize.value
    })
    posts.value = res.data.data?.records || []
    postTotal.value = res.data.data?.total || 0
  } catch (e: any) {
    console.error(e)
    ElMessage.error(e.response?.data?.message || '获取帖子失败')
  }
}

async function handlePinPost(postId: number, pinned: boolean) {
  try {
    await socialApi.pinPost(postId, pinned)
    ElMessage.success(pinned ? '帖子已置顶' : '帖子已取消置顶')
    fetchPosts()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '操作失败')
  }
}

async function handleEssencePost(postId: number, essence: boolean) {
  try {
    await socialApi.essencePost(postId, essence)
    ElMessage.success(essence ? '帖子已设为精华' : '帖子已取消精华')
    fetchPosts()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '操作失败')
  }
}

async function handleDeletePost(postId: number) {
  try {
    await ElMessageBox.confirm('确定删除该帖子？', '确认', { type: 'warning' })
    await socialApi.deletePost(postId)
    ElMessage.success('帖子已删除')
    fetchPosts()
  } catch (e: any) {
    if (e !== 'cancel') ElMessage.error(e.response?.data?.message || '删除失败')
  }
}

async function fetchAllSeasons() {
  try {
    const res = await seasonApi.getAll()
    allSeasons.value = res.data.data || []
  } catch (e) { console.error(e) }
}

async function fetchActiveSeasons() {
  try {
    const res = await seasonApi.getActive()
    activeSeasons.value = res.data.data || []
  } catch (e) { console.error(e) }
}

function showStartNewSeasonDialog() {
  newSeasonForm.value = { league: '', seasonName: '', totalRounds: 38 }
  newSeasonDialogVisible.value = true
}

async function handleStartNewSeason() {
  try {
    if (!newSeasonForm.value.league || !newSeasonForm.value.seasonName) {
      ElMessage.warning('请填写联赛和赛季名称')
      return
    }
    await ElMessageBox.confirm('确定要开启新赛季吗？这将清空当前赛季的所有数据！', '警告', { type: 'warning' })
    await seasonApi.startNew({
      league: newSeasonForm.value.league,
      seasonName: newSeasonForm.value.seasonName,
      totalRounds: newSeasonForm.value.totalRounds
    })
    ElMessage.success('新赛季已开启')
    newSeasonDialogVisible.value = false
    fetchAllSeasons()
    fetchActiveSeasons()
  } catch (e: any) {
    if (e !== 'cancel') ElMessage.error(e.response?.data?.message || '操作失败')
  }
}

async function handleResetSeason(league: string) {
  try {
    await ElMessageBox.confirm('确定要重置 ' + league + ' 的赛季数据吗？这将清空积分榜和球员数据！', '警告', { type: 'warning' })
    await seasonApi.resetSeason(league)
    ElMessage.success('赛季数据已重置')
    fetchAllSeasons()
    fetchActiveSeasons()
  } catch (e: any) {
    if (e !== 'cancel') ElMessage.error(e.response?.data?.message || '操作失败')
  }
}

async function handleFinishSeason(league: string) {
  try {
    await ElMessageBox.confirm('确定要结束 ' + league + ' 当前赛季吗？', '确认', { type: 'warning' })
    await seasonApi.finishSeason(league)
    ElMessage.success('赛季已结束')
    fetchAllSeasons()
    fetchActiveSeasons()
  } catch (e: any) {
    if (e !== 'cancel') ElMessage.error(e.response?.data?.message || '操作失败')
  }
}
</script>

<style scoped lang="scss">
@use '@/styles/tokens' as *;

.page-container {
  background: $surface-dark;
  padding: $space-6 $space-6 $space-8;
  max-width: $content-max-width;
  margin: 0 auto;
}

.admin-tabs {
  .el-tabs--border-card {
    background: $surface-card;
    border: 1px solid $border-subtle;
    border-radius: $radius-xl;
    overflow: hidden;
  }

  // Fix table body white bg
  :deep(.el-table) {
    background: $surface-card !important;
  }

  :deep(.el-table__body-wrapper),
  :deep(.el-table__body),
  :deep(.el-table__row),
  :deep(.el-table__empty-block) {
    background: transparent !important;
  }

  :deep(.el-table__row td) {
    background: transparent !important;
  }

  :deep(.el-table__cell) {
    background: transparent !important;
  }
}

.toolbar {
  display: flex;
  gap: $space-3;
  margin-bottom: $space-5;
  flex-wrap: wrap;
  align-items: center;
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: $space-5;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: $space-4;

  @media (max-width: 800px) {
    grid-template-columns: repeat(2, 1fr);
  }
}

.stat-card {
  text-align: center;
  padding: $space-5;
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-lg;
  transition: all $duration-fast $ease-out;

  &:hover {
    border-color: rgba($purple-primary, 0.3);
    transform: translateY(-2px);
    box-shadow: $shadow-md;
  }

  .stat-value {
    display: block;
    font-family: $font-display;
    font-size: $font-size-2xl;
    font-weight: $font-weight-bold;
    color: $text-primary;
  }

  .stat-label {
    font-size: $font-size-sm;
    color: $text-muted;
    margin-top: 4px;
  }
}

.stats-row-3 {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: $space-3;
  margin-top: $space-4;

  @media (max-width: 900px) {
    grid-template-columns: repeat(4, 1fr);
  }
}

.stat-card-sm {
  text-align: center;
  padding: $space-3;
  background: $surface-mid;
  border: 1px solid $border-subtle;
  border-radius: $radius-md;

  .stat-value-sm {
    display: block;
    font-family: $font-display;
    font-size: $font-size-xl;
    font-weight: $font-weight-bold;
    color: $text-primary;
  }

  .stat-label {
    font-size: $font-size-xs;
    color: $text-muted;
    margin-top: 2px;
  }
}

.analytics-charts-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: $space-4;
  margin-top: $space-5;

  @media (max-width: 900px) {
    grid-template-columns: 1fr;
  }
}

.analytics-chart-card {
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-lg;
  padding: $space-4;

  h4 {
    margin: 0 0 $space-3;
    font-family: $font-display;
    font-size: $font-size-sm;
    font-weight: $font-weight-bold;
    color: $text-secondary;
    letter-spacing: $letter-spacing-wide;
    text-transform: uppercase;
  }
}

.bar-row {
  display: flex;
  align-items: center;
  gap: $space-2;
  margin-bottom: $space-3;

  .bar-label {
    width: 36px;
    font-size: $font-size-sm;
    font-weight: $font-weight-semibold;
    color: $text-muted;
    flex-shrink: 0;
  }

  .bar-track {
    flex: 1;
    height: 8px;
    background: $surface-mid;
    border-radius: $radius-full;
    overflow: hidden;

    .bar-fill {
      height: 100%;
      background: linear-gradient(90deg, $purple-primary, $purple-light);
      border-radius: $radius-full;
      transition: width $duration-slow $ease-out;
    }
  }

  .bar-count {
    width: 36px;
    text-align: right;
    font-size: $font-size-sm;
    font-weight: $font-weight-semibold;
    color: $text-secondary;
    flex-shrink: 0;
  }
}

.io-section {
  h4 {
    margin: 0 0 $space-1;
    font-family: $font-display;
    font-size: $font-size-sm;
    font-weight: $font-weight-bold;
    color: $text-secondary;
    text-transform: uppercase;
    letter-spacing: $letter-spacing-wide;
  }

  p {
    margin: 0;
    font-size: $font-size-xs;
    color: $text-muted;
  }
}

.io-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: $space-4;
}

.io-card {
  background: $surface-card;
  border: 1px solid $border-subtle;
  border-radius: $radius-lg;
  padding: $space-4;
}

.post-user-cell {
  display: flex;
  flex-direction: column;
  gap: 2px;

  .user-name {
    font-weight: $font-weight-medium;
    color: $text-primary;
  }

  .user-club-sm {
    font-size: 11px;
    color: $text-muted;
  }
}

.stat-sm {
  font-size: $font-size-xs;
  color: $text-muted;
  margin-right: $space-2;
}
</style>
