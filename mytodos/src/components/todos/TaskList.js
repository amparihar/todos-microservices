import React, { useState } from 'react';
import { connect } from 'react-redux';
import { Link, withRouter } from 'react-router-dom';
import { Modal } from '../../common';
import ManageGroup from './ManageGroup';

const WrappedTaskList = ({ id: groupId, name: groupName, tasks, ...props }) => {
  const [displayModal, setDisplayModal] = useState(false);
  const handleEditGroupClick = (e) => {
    e.preventDefault();
    setDisplayModal(true);
  };
  // useEffect(() => {
  //   console.log(groupId);
  // }, [groupId]);
  return (
    <div className="card">
      <div className="card-header" onClick={handleEditGroupClick}>
        <h4 style={{ cursor: 'pointer', color: 'blue' }}>{groupName} </h4>
      </div>
      <ul className="list-group list-group-flush">
        {tasks.map((task) => (
          <li key={task.id} className="list-group-item">
            <Link to={`${props.match.url}/task/${task.id}/${groupId}`}>
              {' '}
              <span
                style={
                  task.isComplete
                    ? { textDecoration: 'line-through' }
                    : { textDecoration: 'none' }
                }
              >
                {task.name}
              </span>
            </Link>
          </li>
        ))}
      </ul>
      <div className="card-body">
        <Link to={`${props.match.url}/task/0/${groupId}`}>
          <button className="btn btn-primary" type="button">
            Add Task
          </button>
        </Link>
      </div>
      <Modal display={displayModal}>
        <div className="modal-header">
          <h4>Edit Group</h4>
          <button
            type="button"
            className="close"
            onClick={() => setDisplayModal(false)}
          >
            <span>&times;</span>
          </button>
        </div>
        <div className="modal-body">
          <ManageGroup
            groupId={groupId}
            onClose={() => setDisplayModal(false)}
          />
        </div>
      </Modal>
    </div>
  );
};

const mapStateToProps = (state, ownProps) => {
  const { id: groupId } = ownProps;
  return {
    tasks: state.todos.task.tasks.filter((task) => task.groupId === groupId),
  };
};

export const ConnectedTaskList = connect(mapStateToProps)(
  withRouter(WrappedTaskList)
);
