describe 'Kubernetes cluster setup' do
  def ssh_master(command, timeout:)
    ssh command, '192.168.64.101', timeout: timeout
  end

  def ssh_worker(command, timeout:)
    ssh command, '192.168.64.102', timeout: timeout
  end

  before(:all) do
    wait_for_ssh '192.168.64.101', timeout: 60
    wait_for_ssh '192.168.64.102', timeout: 60
  end

  it 'passes all tests on the master before creating a cluster' do
    result = ssh_master('validate_preflight', timeout: 60).wait

    expect(result.exitstatus).to eq 0
    expect(result.error).to be_nil
  end

  it 'passes all tests on the worker before creating a cluster' do
    result = ssh_worker('validate_preflight', timeout: 60).wait

    expect(result.exitstatus).to eq 0
    expect(result.error).to be_nil
  end

  it 'successfully starts a kubernetes cluster with the master and worker' do
    result = run("ansible-playbook -i hosts_test.ini setup_cluster.yml", timeout: 300).wait

    expect(result.exitstatus).to eq 0
    expect(result.error).to be_nil
  end

  it 'passes all tests on the master after creating a cluster' do
    result = ssh_master('validate_master', timeout: 60).wait

    expect(result.exitstatus).to eq 0
    expect(result.error).to be_nil
  end

  it 'passes all tests on the worker after creating a cluster' do
    result = ssh_worker('validate_worker', timeout: 60).wait

    expect(result.exitstatus).to eq 0
    expect(result.error).to be_nil
  end
end
