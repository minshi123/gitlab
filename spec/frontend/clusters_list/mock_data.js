export const clusterList = [
  {
    name: 'My Cluster 1',
    environmentScope: '*',
    size: '3',
    clusterType: 'group_type',
    status: 'disabled',
    cpu: '6 (100% free)',
    memory: '22.50 (30% free)',
  },
  {
    name: 'My Cluster 2',
    environmentScope: 'development',
    size: '12',
    clusterType: 'project_type',
    status: 'unreachable',
    cpu: '3 (50% free)',
    memory: '11 (60% free)',
  },
  {
    name: 'My Cluster 3',
    environmentScope: 'development',
    size: '12',
    clusterType: 'project_type',
    status: 'authentication_failure',
    cpu: '1 (0% free)',
    memory: '22 (33% free)',
  },
  {
    name: 'My Cluster 4',
    environmentScope: 'production',
    size: '12',
    clusterType: 'project_type',
    status: 'deleting',
    cpu: '6 (100% free)',
    memory: '45 (15% free)',
  },
  {
    name: 'My Cluster 5',
    environmentScope: 'development',
    size: '12',
    clusterType: 'project_type',
    status: 'created',
    cpu: '6 (100% free)',
    memory: '20.12 (35% free)',
  },
];

export const apiData = {
  clusters: clusterList,
  has_ancestor_clusters: false,
};
