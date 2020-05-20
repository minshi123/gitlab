import longNoParallel from './long_no_parallel.json';
import * as longNoParallelOutput from './long_no_parallel_output';
import mixedParallel from './mixed_parallel.json';
import parallelNeesdsSingle from './parallel_needs_single.json';

/**
  It is important that the simple base include parallel jobs
  as well as non-parallel jobs with spaces in the name to prevent
  us relying on spaces as an indicator.
**/
const simpleBase = {
  stages: [
    {
      name: 'test',
      groups: [
        {
          name: 'jest',
          size: 2,
          jobs: [
            { name: 'jest 1/2', needs: ['frontend fixtures'] },
            { name: 'jest 2/2' }
          ]
        },
        {
          name: 'rspec',
          size: 1,
          jobs: [
            { name: 'rspec', needs: ['frontend fixtures'] },
          ]
        },
      ]
    },
    {
      name: 'fixtures',
      groups: [
        {
          name: 'frontend fixtures',
          size: 1,
          jobs: [
            { name: 'frontend fixtures' }
          ]
        }
      ]
    },
    {
      name: 'un-needed',
      groups: [
        {
          name: 'un-needed',
          size: 1,
          jobs: [
            { name: 'un-needed' }
          ]
        }
      ]
    }
  ]
}

export {
  longNoParallel,
  longNoParallelOutput,
  mixedParallel,
  // mixedParallelOutput,
  parallelNeesdsSingle,
  // parallelNeesdsSingleOutput,
  simpleBase,
};
