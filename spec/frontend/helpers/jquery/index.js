import $ from './expose';
import '~/commons/jquery';

// Fail tests for unmocked requests
$.ajax = () => {
  const err = new Error(
    'Unexpected unmocked jQuery.ajax() call! Make sure to mock jQuery.ajax() in tests.',
  );
  global.fail(err);
  throw err;
};

export default $;
