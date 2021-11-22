// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7 <0.9.0;

contract crowFunding {
    
    enum projectState {open, closed}
    
    struct Contribution{
        address contributor;
        uint value;
    }
    
    struct Project {
        string id;
        string name;
        string description;
        address payable author;
        projectState state;
        uint dreamFounds;
        uint totalFunds;
    }
    

    Project[] public projects;
    
    mapping(string => Contribution[]) public contributions;

  //  constructor(string memory _id, string memory _name, string memory _description, uint _dreamFounds) {
  //      project = Project(_id, _name, _description, payable(msg.sender), projectState.open, 0, _dreamFounds);
  //      
  //      projectsBuild.push(project);
  //  }
    

    
    
    event projectCreated(string projectsId, string projectsName, string projectsDescription, uint projectsDreamFounds);
    
    event FundProject(address donador, string projectId, uint donacion, uint gasDonacion);    

    event ChangeProject(address editor, string projectId, projectState NewState);
    
    modifier noAuthor(uint projectIndex) {
        require(projects[projectIndex].author != msg.sender, "El author no puede enviar dinero a su propio proyecto");
        
        require(msg.value > 0, "El valor aportado no puede ser cero o menos");
        
        _;  }
        
    modifier onlyAuthor(uint projectIndex) {
        require(projects[projectIndex].author == msg.sender, "Solamente el propietario puede cerrar el contrato");
        
        _;
    }    

    
    function createProject(string calldata id, string calldata name, string calldata description, uint dreamFounds) public {
        require(dreamFounds > 0, "El objetivo debe ser mayor a 0");
        Project memory project = Project(id, name, description, payable(msg.sender), projectState.open, dreamFounds, 0);
        projects.push(project);
        emit projectCreated(id, name, description, dreamFounds);
    }
    

        
    
    function fundProject(uint projectIndex) payable public noAuthor(projectIndex){
        Project memory project = projects[projectIndex];
        require(projects[projectIndex].state == projectState.open, "Para enviar fondos debe estar abierto el contrato");
        project.author.transfer(msg.value);
        project.totalFunds += msg.value;
        projects[projectIndex] = project;
        
        contributions[project.id].push(Contribution(msg.sender, msg.value));
        
        emit FundProject(msg.sender, project.id,msg.value, tx.gasprice);
    }
    

    
    
    function changeProject(projectState newState, uint projectIndex) public onlyAuthor(projectIndex){
        Project memory project = projects[projectIndex];
        require(project.state != newState, "El nuevo estado del contrato no puede ser igual que el actual, 0 = activo / 1 = cerrado");
        project.state = newState;
        projects[projectIndex] = project;
        
        emit ChangeProject(msg.sender, project.id, newState);
    }
}