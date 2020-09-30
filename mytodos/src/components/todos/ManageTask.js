import React from 'react';
import { useParams } from 'react-router-dom';
import { connect } from 'react-redux';

import TaskForm from './TaskForm';
import * as actions from '../../store/actions';

const ManageTask = ({ task, saveTask, ...props }) => {
  return (
    <>
      <h5>Manage Task</h5>
      <TaskForm task={task} save={saveTask} />
    </>
  );
};

const mapStateToProps = (state, ownProps) => {
  // ** Hooks cannot be called conditionally or inside a function
  //const { groupId, taskId } = useParams();
  const { groupId, taskId } = ownProps.match.params;
  return {
    task: state.todos.task.tasks.find(task => task.id === taskId) || {
      name: '',
      id: '',
      groupId,
      isComplete: false
    }
  };
};

const mapDispatchToProps = {
  saveTask: actions.requestSaveTask
};

export const ConnectedManageTask = connect(
  mapStateToProps,
  mapDispatchToProps
)(ManageTask);
